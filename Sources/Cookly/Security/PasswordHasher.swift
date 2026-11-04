import CryptoKit
import Foundation

/// Reglas de contraseña nuevas. El login sigue aceptando las antiguas para migrar.
enum PasswordPolicy {
    static let hint = "Mínimo 8 caracteres, con una letra y un número. No uses 12345678, password ni tu usuario."
    static let minLength = 8

    static func validate(_ password: String, username: String) -> String? {
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if password.count < minLength { return hint }
        let hasLetter = password.contains { $0.isLetter }
        let hasNumber = password.contains { $0.isNumber }
        if !hasLetter || !hasNumber { return hint }
        let lowered = password.lowercased()
        if lowered == "12345678" || lowered == "password" || lowered == trimmedUser {
            return hint
        }
        return nil
    }
}

/// Sal de 16 bytes y SHA-256. La versión 2 itera el digest; la 1 es el hash simple anterior.
enum PasswordHasher {
    static let currentVersion = 2
    static let iterations = 50_000

    static func makeSalt() -> String {
        let key = SymmetricKey(size: .bits128)
        return key.withUnsafeBytes { Data($0).base64EncodedString() }
    }

    static func hash(password: String, salt: String, version: Int) -> String {
        if version <= 1 {
            let material = Data(salt.utf8) + Data(password.utf8)
            return hex(Data(SHA256.hash(data: material)))
        }
        var data = Data(salt.utf8) + Data(password.utf8)
        for _ in 0..<iterations {
            data = Data(SHA256.hash(data: data))
        }
        return hex(data)
    }

    static func verify(password: String, salt: String, hash: String, version: Int) -> Bool {
        equal(self.hash(password: password, salt: salt, version: version), hash)
    }

    /// Mismo coste que un verify real cuando el usuario no existe.
    static func dummyVerify(password: String) {
        _ = hash(password: password, salt: "cookly.padding", version: currentVersion)
    }

    /// Comparación en tiempo constante: XOR de cada byte, sin == sobre Data.
    static func equal(_ left: String, _ right: String) -> Bool {
        let a = [UInt8](left.utf8)
        let b = [UInt8](right.utf8)
        var diff: UInt8 = UInt8(truncatingIfNeeded: a.count ^ b.count) == 0 ? 0 : 1
        let count = max(a.count, b.count)
        var index = 0
        while index < count {
            let x = index < a.count ? a[index] : 0
            let y = index < b.count ? b[index] : 0
            diff |= x ^ y
            index += 1
        }
        return diff == 0
    }

    private static func hex<D: Sequence>(_ bytes: D) -> String where D.Element == UInt8 {
        bytes.map { String(format: "%02x", $0) }.joined()
    }
}
