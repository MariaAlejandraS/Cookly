import Combine
import Foundation

enum RegisterFailure: Error, Equatable {
    case invalidName
    case invalidUsername
    case weakPassword
    case duplicateUsername
}

enum LoginResult: Equatable {
    case success
    case invalid
    case locked(seconds: Int)
}

/// Sesión local. El id se restaura desde UserDefaults al abrir la app.
@MainActor
final class SessionManager: ObservableObject {
    static private(set) var shared: SessionManager?

    @Published private(set) var currentUser: User?
    @Published private(set) var formEpoch = 0

    private let store: any LocalStore
    private static let sessionKey = "cookly.currentUserId"
    private static let lockPrefix = "cookly.lockout."

    init(store: (any LocalStore)? = nil) {
        let resolved = store ?? PersistenceFactory.make()
        self.store = resolved
        SessionManager.shared = self
        restore()
    }

    var ownerId: UUID? { currentUser?.id }

    func register(name: String, username: String, password: String) async -> Result<Void, RegisterFailure> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = Self.normalizeUsername(username)
        guard !trimmedName.isEmpty else { return .failure(.invalidName) }
        guard Self.isValidUsername(normalized) else { return .failure(.invalidUsername) }
        if PasswordPolicy.validate(password, username: normalized) != nil {
            return .failure(.weakPassword)
        }
        if store.fetchUsers().contains(where: { $0.username == normalized }) {
            return .failure(.duplicateUsername)
        }
        let salt = PasswordHasher.makeSalt()
        let digest = await Task.detached {
            PasswordHasher.hash(password: password, salt: salt, version: PasswordHasher.currentVersion)
        }.value
        let user = User(
            id: UUID(),
            name: trimmedName,
            username: normalized,
            passwordHash: digest,
            salt: salt,
            createdAt: .now,
            hashVersion: PasswordHasher.currentVersion
        )
        store.insert(user)
        adopt(user)
        return .success(())
    }

    /// No revela si el usuario existe. El hash de relleno iguala el tiempo si no hay cuenta.
    func login(username: String, password: String) async -> LoginResult {
        let normalized = Self.normalizeUsername(username)
        if let wait = lockRemaining(for: normalized), wait > 0 {
            return .locked(seconds: wait)
        }

        let match = store.fetchUsers().first(where: { $0.username == normalized })
        let salt = match?.salt ?? ""
        let stored = match?.passwordHash ?? ""
        let version = match?.hashVersion ?? PasswordHasher.currentVersion
        let existed = match != nil

        let accepted = await Task.detached {
            if existed {
                return PasswordHasher.verify(password: password, salt: salt, hash: stored, version: version)
            }
            PasswordHasher.dummyVerify(password: password)
            return false
        }.value

        guard accepted, var user = match else {
            if let wait = recordFailure(for: normalized) {
                return .locked(seconds: wait)
            }
            return .invalid
        }

        clearLock(for: normalized)
        if user.hashVersion < PasswordHasher.currentVersion {
            user = await migrateHash(user, password: password)
        }
        adopt(user)
        return .success
    }

    func updateName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var user = currentUser else { return }
        user.name = trimmed
        store.update(user)
        currentUser = user
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: Self.sessionKey)
        formEpoch += 1
    }

    func lockRemaining(for username: String) -> Int? {
        let normalized = Self.normalizeUsername(username)
        guard let record = loadLock(normalized), record.until > 0 else { return nil }
        let left = Int(ceil(record.until - Date().timeIntervalSince1970))
        if left <= 0 {
            var open = record
            open.until = 0
            saveLock(open, username: normalized)
            return nil
        }
        return left
    }

    static func normalizeUsername(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValidUsername(_ normalized: String) -> Bool {
        guard (3...20).contains(normalized.count) else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")
        return normalized.unicodeScalars.allSatisfy(allowed.contains)
    }

    private func adopt(_ user: User) {
        currentUser = user
        UserDefaults.standard.set(user.id.uuidString, forKey: Self.sessionKey)
    }

    private func restore() {
        guard let raw = UserDefaults.standard.string(forKey: Self.sessionKey),
              let id = UUID(uuidString: raw),
              let user = store.fetchUsers().first(where: { $0.id == id }) else {
            UserDefaults.standard.removeObject(forKey: Self.sessionKey)
            currentUser = nil
            return
        }
        currentUser = user
    }

    private func migrateHash(_ user: User, password: String) async -> User {
        var updated = user
        let salt = PasswordHasher.makeSalt()
        let digest = await Task.detached {
            PasswordHasher.hash(password: password, salt: salt, version: PasswordHasher.currentVersion)
        }.value
        updated.salt = salt
        updated.passwordHash = digest
        updated.hashVersion = PasswordHasher.currentVersion
        store.update(updated)
        return updated
    }

    private func recordFailure(for username: String) -> Int? {
        var record = loadLock(username) ?? LockRecord(fails: 0, until: 0, nextPenalty: 30)
        record.fails += 1
        if record.fails >= 5 {
            record.until = Date().timeIntervalSince1970 + TimeInterval(record.nextPenalty)
            record.fails = 0
            record.nextPenalty = min(record.nextPenalty * 2, 300)
            saveLock(record, username: username)
            return Int(ceil(record.until - Date().timeIntervalSince1970))
        }
        saveLock(record, username: username)
        return nil
    }

    private func clearLock(for username: String) {
        UserDefaults.standard.removeObject(forKey: Self.lockPrefix + username)
    }

    private func loadLock(_ username: String) -> LockRecord? {
        guard let data = UserDefaults.standard.data(forKey: Self.lockPrefix + username) else { return nil }
        return try? JSONDecoder().decode(LockRecord.self, from: data)
    }

    private func saveLock(_ record: LockRecord, username: String) {
        if let data = try? JSONEncoder().encode(record) {
            UserDefaults.standard.set(data, forKey: Self.lockPrefix + username)
        }
    }
}

private struct LockRecord: Codable {
    var fails: Int
    var until: TimeInterval
    var nextPenalty: Int
}
