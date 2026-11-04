import Foundation

/// Cuenta local. La contraseña no se guarda: solo el hash, la sal y la versión.
struct User: Identifiable, Hashable {
    var id: UUID
    var name: String
    var username: String
    var passwordHash: String
    var salt: String
    var createdAt: Date
    var hashVersion: Int = 1

    /// Dueño de productos y recordatorios creados antes de las cuentas.
    static let unassignedOwner = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, username, passwordHash, salt, createdAt, hashVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        passwordHash = try container.decode(String.self, forKey: .passwordHash)
        salt = try container.decode(String.self, forKey: .salt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        hashVersion = try container.decodeIfPresent(Int.self, forKey: .hashVersion) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(passwordHash, forKey: .passwordHash)
        try container.encode(salt, forKey: .salt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(hashVersion, forKey: .hashVersion)
    }
}
