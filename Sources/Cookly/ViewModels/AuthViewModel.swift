import Combine
import Foundation

enum AuthField: Hashable {
    case name
    case username
    case password
}

/// Validación de registro e inicio de sesión. Los textos de error están en español.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var name = ""
    @Published var username = ""
    @Published var password = ""
    @Published var nameError: String?
    @Published var usernameError: String?
    @Published var passwordError: String?
    @Published var loginError: String?
    @Published private(set) var isBusy = false
    @Published private(set) var lockSeconds = 0

    private var lockTask: Task<Void, Never>?

    var isLocked: Bool { lockSeconds > 0 }

    var canLogin: Bool {
        SessionManager.isValidUsername(SessionManager.normalizeUsername(username))
            && !password.isEmpty
            && !isBusy
            && !isLocked
    }

    var canRegister: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && SessionManager.isValidUsername(SessionManager.normalizeUsername(username))
            && PasswordPolicy.validate(password, username: username) == nil
            && !isBusy
    }

    func reset() {
        lockTask?.cancel()
        name = ""
        username = ""
        password = ""
        nameError = nil
        usernameError = nil
        passwordError = nil
        loginError = nil
        isBusy = false
        lockSeconds = 0
    }

    func validate(showEmpty: Bool, forRegister: Bool = false) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            nameError = showEmpty ? "Escribe tu nombre." : nil
        } else {
            nameError = nil
        }

        let normalized = SessionManager.normalizeUsername(username)
        if normalized.isEmpty {
            usernameError = showEmpty ? "Usa de 3 a 20 letras, números o guion bajo." : nil
        } else if !SessionManager.isValidUsername(normalized) {
            usernameError = "Usa de 3 a 20 letras, números o guion bajo."
        } else if usernameError != "Ese usuario ya existe." {
            usernameError = nil
        }

        if forRegister {
            if password.isEmpty {
                passwordError = showEmpty ? PasswordPolicy.hint : nil
            } else {
                passwordError = PasswordPolicy.validate(password, username: normalized)
            }
        }
    }

    func refreshLock(using session: SessionManager) {
        if let wait = session.lockRemaining(for: username), wait > 0 {
            beginLock(wait)
        } else if isLocked {
            lockTask?.cancel()
            lockSeconds = 0
            loginError = nil
        }
    }

    func login(using session: SessionManager) {
        guard !isBusy, !isLocked else { return }
        loginError = nil
        let normalized = SessionManager.normalizeUsername(username)
        guard SessionManager.isValidUsername(normalized), !password.isEmpty else {
            validate(showEmpty: true)
            return
        }
        isBusy = true
        Task {
            let result = await session.login(username: username, password: password)
            password = ""
            isBusy = false
            switch result {
            case .success:
                loginError = nil
            case .invalid:
                loginError = "Usuario o contraseña incorrectos."
            case .locked(let seconds):
                beginLock(seconds)
            }
        }
    }

    func register(using session: SessionManager) {
        guard !isBusy else { return }
        loginError = nil
        validate(showEmpty: true, forRegister: true)
        guard canRegister else { return }
        isBusy = true
        Task {
            let result = await session.register(name: name, username: username, password: password)
            isBusy = false
            switch result {
            case .success:
                password = ""
            case .failure(.duplicateUsername):
                usernameError = "Ese usuario ya existe."
            case .failure(.invalidName):
                nameError = "Escribe tu nombre."
            case .failure(.invalidUsername):
                usernameError = "Usa de 3 a 20 letras, números o guion bajo."
            case .failure(.weakPassword):
                passwordError = PasswordPolicy.hint
            }
        }
    }

    private func beginLock(_ seconds: Int) {
        lockTask?.cancel()
        lockSeconds = seconds
        loginError = Self.lockMessage(seconds)
        lockTask = Task { @MainActor in
            while !Task.isCancelled, lockSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                lockSeconds -= 1
                if lockSeconds > 0 {
                    loginError = Self.lockMessage(lockSeconds)
                } else {
                    loginError = nil
                }
            }
        }
    }

    private static func lockMessage(_ seconds: Int) -> String {
        "Demasiados intentos. Intenta de nuevo en \(seconds) s."
    }
}
