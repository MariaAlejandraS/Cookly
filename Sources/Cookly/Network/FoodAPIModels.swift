import Foundation

// Modelos Codable que reflejan el JSON de Open Food Facts.
// Codable = Decodable + Encodable; JSONDecoder los llena automáticamente
// (equivale a usar Gson/Moshi o kotlinx.serialization en Android).

/// Respuesta de búsqueda: GET /cgi/search.pl?...&json=1
struct OFFSearchResponse: Decodable {
    let count: Int?
    let products: [OFFProduct]
}

/// Respuesta de producto por código de barras: GET /api/v2/product/{code}.json
struct OFFProductResponse: Decodable {
    let status: Int          // 1 = encontrado, 0 = no existe
    let product: OFFProduct?
}

struct OFFProduct: Decodable, Identifiable, Hashable {
    let code: String
    let productName: String?
    let brands: String?
    let quantity: String?
    let imageURL: String?
    let nutriscoreGrade: String?
    let novaGroup: Int?
    let categoriesTags: [String]?
    let ingredientsText: String?
    let allergens: String?

    var id: String { code }

    var displayName: String {
        let name = productName?.trimmingCharacters(in: .whitespaces) ?? ""
        return name.isEmpty ? "Producto sin nombre" : name
    }

    /// Las claves del JSON vienen en snake_case; aquí las mapeamos a camelCase.
    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case quantity
        case imageURL = "image_front_small_url"
        case nutriscoreGrade = "nutriscore_grade"
        case novaGroup = "nova_group"
        case categoriesTags = "categories_tags"
        case ingredientsText = "ingredients_text"
        case allergens
    }

    // Decodificación tolerante: si un campo falta o viene con otro tipo, queda en nil
    // en vez de romper toda la respuesta.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        code = (try? c.decode(String.self, forKey: .code)) ?? UUID().uuidString
        productName = try? c.decode(String.self, forKey: .productName)
        brands = try? c.decode(String.self, forKey: .brands)
        quantity = try? c.decode(String.self, forKey: .quantity)
        imageURL = try? c.decode(String.self, forKey: .imageURL)
        nutriscoreGrade = try? c.decode(String.self, forKey: .nutriscoreGrade)
        novaGroup = try? c.decode(Int.self, forKey: .novaGroup)
        categoriesTags = try? c.decode([String].self, forKey: .categoriesTags)
        ingredientsText = try? c.decode(String.self, forKey: .ingredientsText)
        allergens = try? c.decode(String.self, forKey: .allergens)
    }
}
