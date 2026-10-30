import Foundation

/// Errores de red que la UI puede mostrar en español.
enum APIError: LocalizedError {
    case invalidURL
    case badStatus(Int)
    case notFound
    case decoding
    case noConnection
    /// Open Food Facts permite unas 10 búsquedas por minuto.
    case tooManyRequests
    case timedOut
    case connectionLost

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La dirección de la consulta no es válida."
        case .badStatus(let code): return "El servidor respondió con error (\(code))."
        case .notFound: return "No encontramos ese producto."
        case .decoding: return "No pudimos leer la respuesta del servidor."
        case .noConnection: return "Sin conexión a internet. Revisa tu red e intenta de nuevo."
        case .tooManyRequests: return "Demasiadas búsquedas seguidas, espera un minuto."
        case .timedOut: return "La consulta tardó demasiado. Revisa tu conexión e intenta de nuevo."
        case .connectionLost: return "Se perdió la conexión a internet. Intenta de nuevo."
        }
    }
}

/// Módulo de RED: consume la API REST pública de Open Food Facts con URLSession + async/await.
/// (En Android esto sería un servicio Retrofit con funciones `suspend`.)
/// No necesita API key, pero Open Food Facts pide un User-Agent con un correo de contacto.
final class FoodAPIService: Sendable {
    private static var cached: FoodAPIService?

    static var shared: FoodAPIService {
        if let cached { return cached }
        let service = FoodAPIService()
        cached = service
        return service
    }

    /// Correos del equipo. Open Food Facts pide un contacto dentro del User-Agent.
    static let contactEmail = "ronalvaldez@unicauca.edu.co, msolarteastaiza@unicauca.edu.co"

    private let baseURL = "https://world.openfoodfacts.org"
    private let session: URLSession
    private var userAgent: String { "Cookly-iOS/1.0 (\(Self.contactEmail))" }

    /// Solo pedimos los campos que usamos: respuesta más liviana y rápida.
    private let fields = "code,product_name,brands,quantity,image_front_small_url,nutriscore_grade,nova_group,categories_tags,ingredients_text,allergens"

    init(session: URLSession? = nil) {
        self.session = session ?? .shared
    }

    /// Busca productos por nombre. GET /cgi/search.pl?search_terms=...&json=1
    func searchProducts(query: String) async throws -> [OFFProduct] {
        var comps = URLComponents(string: "\(baseURL)/cgi/search.pl")
        comps?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "fields", value: fields)
        ]
        guard let url = comps?.url else { throw APIError.invalidURL }
        let response: OFFSearchResponse = try await get(url)
        return response.products
    }

    /// Trae el detalle de un producto por código de barras. GET /api/v2/product/{code}.json
    func fetchProduct(barcode: String) async throws -> OFFProduct {
        var comps = URLComponents(string: "\(baseURL)/api/v2/product/\(barcode).json")
        comps?.queryItems = [URLQueryItem(name: "fields", value: fields)]
        guard let url = comps?.url else { throw APIError.invalidURL }
        let response: OFFProductResponse = try await get(url)
        guard response.status == 1, let product = response.product else { throw APIError.notFound }
        return product
    }

    /// Función genérica: hace la petición GET y decodifica el JSON al tipo T.
    private func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError {
            switch error.code {
            case .cancelled:
                throw error
            case .notConnectedToInternet, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .dataNotAllowed:
                throw APIError.noConnection
            case .timedOut:
                throw APIError.timedOut
            case .networkConnectionLost:
                throw APIError.connectionLost
            default:
                throw error
            }
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if http.statusCode == 404 { throw APIError.notFound }
            if http.statusCode == 429 { throw APIError.tooManyRequests }
            throw APIError.badStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
