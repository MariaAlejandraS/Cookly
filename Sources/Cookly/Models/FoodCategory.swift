import Foundation

/// Categorías de refrigeración alineadas con la guía de FDA FoodSafety.gov
/// y USDA FoodKeeper (las mismas 11 de la versión Android).
/// La fecha sugerida usa `minDays`: el extremo corto, por seguridad alimentaria.
enum FoodCategory: String, CaseIterable, Identifiable, Codable {
    case carneMolida = "Carne molida"
    case cortesCarne = "Cortes enteros de carne"
    case polloPavo = "Pollo o pavo crudo"
    case pescadoMariscos = "Pescado y mariscos crudos"
    case comidaCocida = "Comida cocida/sobras"
    case embutidos = "Embutidos o fiambres abiertos"
    case lacteosAbiertos = "Lácteos abiertos"
    case verdurasHoja = "Verduras de hoja"
    case frutasBlandas = "Frutas blandas"
    case frutasFirmes = "Frutas firmes"
    case otros = "Otros/enlatados abiertos"

    var id: String { rawValue }

    /// Mínimo de días en refrigeración. La fecha sugerida es hoy + este valor.
    var minDays: Int {
        switch self {
        case .carneMolida: return 1
        case .cortesCarne: return 3
        case .polloPavo: return 1
        case .pescadoMariscos: return 1
        case .comidaCocida: return 3
        case .embutidos: return 3
        case .lacteosAbiertos: return 5
        case .verdurasHoja: return 3
        case .frutasBlandas: return 1
        case .frutasFirmes: return 5
        case .otros: return 3
        }
    }

    /// Máximo de días en refrigeración, solo para mostrar el rango recomendado.
    var maxDays: Int {
        switch self {
        case .carneMolida: return 2
        case .cortesCarne: return 5
        case .polloPavo: return 2
        case .pescadoMariscos: return 2
        case .comidaCocida: return 4
        case .embutidos: return 5
        case .lacteosAbiertos: return 7
        case .verdurasHoja: return 7
        case .frutasBlandas: return 2
        case .frutasFirmes: return 7
        case .otros: return 5
        }
    }

    /// SF Symbols usados aquí (verificar en la app SF Symbols, filtro iOS 17):
    /// fork.knife, fish.fill, cup.and.saucer.fill, leaf.fill, basket.fill.
    var icon: String {
        switch self {
        case .carneMolida, .cortesCarne, .polloPavo, .comidaCocida, .embutidos:
            return "fork.knife"
        case .pescadoMariscos:
            return "fish.fill"
        case .lacteosAbiertos:
            return "cup.and.saucer.fill"
        case .verdurasHoja, .frutasBlandas, .frutasFirmes:
            return "leaf.fill"
        case .otros:
            return "basket.fill"
        }
    }

    /// Etiquetas `en:` de Open Food Facts → categoría Cookly.
    /// Si varias encajan, gana la de menor `minDays`.
    /// Una etiqueta concreta (manzana, pollo) le gana a la genérica (`en:fruits`, `en:meats`).
    /// Solo ante una etiqueta genérica se elige el mínimo: fruta → blandas (1), carne → molida (1).
    static func from(offTags: [String]) -> FoodCategory {
        let words = tokens(from: offTags)
        // Una lata cerrada no es pescado crudo: «Otros/enlatados» ya cubre 3–5 días.
        if hits(words, ["canned", "tinned", "conserve", "enlatado"]) {
            return .otros
        }
        let plantBased = hits(words, ["vegan", "vegetarian", "plant", "coconut", "almond", "soy", "oat", "alternatives", "analogues", "substitutes", "tofu", "tempeh", "seitan"])
        let isDrink = hits(words, ["fruit-juices", "juice", "juices", "drink", "drinks", "beverage", "beverages", "nectar", "soda", "tea", "coffee", "water"])
        var matches: [FoodCategory] = []

        if !plantBased && hits(words, ["ground-meat", "ground-beef", "ground-pork", "minced", "mince", "hamburger", "meatball"]) {
            matches.append(.carneMolida)
        }
        if !plantBased && hits(words, ["chicken", "chickens", "turkey", "poultry", "pollo", "pavo"]) {
            matches.append(.polloPavo)
        }
        if !plantBased && hits(words, ["fish", "seafood", "shellfish", "salmon", "tuna", "shrimp", "prawn", "sardine", "poisson", "pescado"]) {
            matches.append(.pescadoMariscos)
        }
        if !plantBased && hits(words, ["sausage", "sausages", "salami", "ham", "chorizo", "bacon", "charcuterie", "cold-cut", "deli", "jambon", "embutido"]) {
            matches.append(.embutidos)
        }
        if hits(words, ["leftover", "ready-meal", "cooked"]) {
            matches.append(.comidaCocida)
        }
        if !plantBased && hits(words, ["steak", "roast", "chop", "beef", "pork", "lamb", "veal"]) {
            matches.append(.cortesCarne)
        }
        if !plantBased && hits(words, ["dairy", "dairies", "milk", "milks", "cheese", "cheeses", "yogurt", "yogurts", "yoghurt", "butter", "lait", "leche", "fromage", "queso", "yaourt", "yogur"]) {
            matches.append(.lacteosAbiertos)
        }
        if hits(words, ["lettuce", "spinach", "salad", "kale", "chard", "arugula", "cabbage", "leafy", "vegetable", "vegetables", "verdura", "legume"]) {
            matches.append(.verdurasHoja)
        }
        if !isDrink && hits(words, ["berry", "strawberry", "raspberry", "blueberry", "blackberry", "banana", "peach", "plum", "grape", "kiwi", "mango", "melon", "cherry", "pineapple", "tomato", "apricot"]) {
            matches.append(.frutasBlandas)
        }
        if !isDrink && hits(words, ["apple", "pear", "orange", "lemon", "lime", "grapefruit", "citrus"]) {
            matches.append(.frutasFirmes)
        }
        if isDrink || hits(words, ["canned", "tinned", "conserve", "enlatado", "bread", "breads", "pain", "pan", "egg", "eggs"]) {
            matches.append(.otros)
        }

        if !matches.isEmpty {
            return moreUrgent(matches)
        }

        if !isDrink && hits(words, ["fruit", "fruits", "fruta"]) { return .frutasBlandas }
        if !plantBased && hits(words, ["meat", "meats", "viande", "carne"]) { return .carneMolida }
        return .otros
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let known = FoodCategory(rawValue: raw) {
            self = known
        } else if let legacy = Self.legacy(raw) {
            // Archivos guardados con el enum anterior: no se tira la lista.
            self = legacy
        } else {
            self = .otros
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    /// Nombres del enum viejo. Donde el nombre era ambiguo, se usa la de menor minDays.
    private static func legacy(_ raw: String) -> FoodCategory? {
        switch raw {
        case "Lácteos": return .lacteosAbiertos
        case "Carnes": return .carneMolida
        case "Pescados y mariscos": return .pescadoMariscos
        case "Frutas": return .frutasBlandas
        case "Verduras": return .verdurasHoja
        case "Panadería", "Huevos", "Bebidas", "Enlatados", "Congelados", "Otros": return .otros
        default: return nil
        }
    }

    private static func moreUrgent(_ matches: [FoodCategory]) -> FoodCategory {
        matches.min { a, b in
            if a.minDays != b.minDays { return a.minDays < b.minDays }
            return specificity(a) > specificity(b)
        } ?? .otros
    }

    /// Desempate cuando el mínimo de días coincide: gana la etiqueta más concreta.
    private static func specificity(_ category: FoodCategory) -> Int {
        switch category {
        case .carneMolida, .polloPavo, .pescadoMariscos: return 5
        case .embutidos, .frutasBlandas, .frutasFirmes, .lacteosAbiertos: return 4
        case .comidaCocida, .verdurasHoja: return 3
        case .cortesCarne: return 2
        case .otros: return 1
        }
    }

    /// Parte cada etiqueta por `:`, `-`, `_` y espacios. La clave solo gana si
    /// todas sus palabras están tal cual (así `pan` no pega en `spanish`).
    /// Se omiten las etiquetas `*-based-foods*`: van en casi todo vegetal y
    /// disparan «bebida» o «verdura». `en:beverages` sí se conserva.
    private static func tokens(from tags: [String]) -> Set<String> {
        var words = Set<String>()
        for tag in tags {
            let lower = tag.lowercased()
            if lower.contains("-based-foods") { continue }
            let pieces = lower.split { character in
                character == ":" || character == "-" || character == "_" || character.isWhitespace
            }
            for piece in pieces where !piece.isEmpty {
                insertWord(String(piece), into: &words)
            }
        }
        return words
    }

    /// Guarda la palabra y su singular: berries→berry, tomatoes→tomato, apples→apple.
    private static func insertWord(_ word: String, into words: inout Set<String>) {
        words.insert(word)
        if word.hasSuffix("ies"), word.count > 3 {
            words.insert(String(word.dropLast(3)) + "y")
        } else if word.hasSuffix("es"), word.count > 2 {
            words.insert(String(word.dropLast(2)))
            words.insert(String(word.dropLast(1)))
        } else if word.hasSuffix("s"), word.count > 1 {
            words.insert(String(word.dropLast(1)))
        }
    }

    private static func hits(_ words: Set<String>, _ keywords: [String]) -> Bool {
        keywords.contains { keyword in
            let parts = keyword.lowercased().split { character in
                character == ":" || character == "-" || character == "_" || character.isWhitespace
            }.map(String.init)
            return !parts.isEmpty && parts.allSatisfy(words.contains)
        }
    }
}
