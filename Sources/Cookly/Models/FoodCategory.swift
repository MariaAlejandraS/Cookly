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
        let tags = offTags.joined(separator: " ").lowercased()
        let plantBased = hits(tags, ["vegan", "vegetarian", "plant", "coconut", "almond", "soy", "oat"])
        var matches: [FoodCategory] = []

        if !plantBased && hits(tags, ["ground-meat", "ground-beef", "ground-pork", "minced", "mince", "hamburger", "meatball"]) {
            matches.append(.carneMolida)
        }
        if !plantBased && hits(tags, ["chicken", "turkey", "poultry", "pollo", "pavo"]) {
            matches.append(.polloPavo)
        }
        if !plantBased && hits(tags, ["fish", "seafood", "shellfish", "salmon", "tuna", "shrimp", "prawn", "sardine"]) {
            matches.append(.pescadoMariscos)
        }
        if !plantBased && hits(tags, ["sausage", "salami", "ham", "chorizo", "bacon", "charcuterie", "cold-cut", "deli"]) {
            matches.append(.embutidos)
        }
        if hits(tags, ["leftover", "ready-meal", "cooked"]) {
            matches.append(.comidaCocida)
        }
        if !plantBased && hits(tags, ["steak", "roast", "chop", "beef", "pork", "lamb", "veal"]) {
            matches.append(.cortesCarne)
        }
        if !plantBased && hits(tags, ["dairy", "dair", "milk", "cheese", "yogurt", "yoghurt", "butter"]) {
            matches.append(.lacteosAbiertos)
        }
        if hits(tags, ["lettuce", "spinach", "salad", "kale", "chard", "arugula", "cabbage", "leafy", "vegetable", "verdura"]) {
            matches.append(.verdurasHoja)
        }
        if hits(tags, ["berry", "strawberry", "raspberry", "blueberry", "blackberry", "banana", "peach", "plum", "grape", "kiwi", "mango", "melon", "cherry", "pineapple", "tomato", "apricot"]) {
            matches.append(.frutasBlandas)
        }
        if hits(tags, ["apple", "pear", "orange", "lemon", "lime", "grapefruit", "citrus"]) {
            matches.append(.frutasFirmes)
        }
        if hits(tags, ["canned", "tinned"]) {
            matches.append(.otros)
        }

        if !matches.isEmpty {
            return moreUrgent(matches)
        }

        // Sin etiqueta concreta: la duda se resuelve por el mínimo de días.
        if hits(tags, ["juice", "nectar", "beverage", "drink", "soda", "tea", "coffee", "water"]) {
            return .otros
        }
        if hits(tags, ["fruit"]) { return .frutasBlandas }
        if hits(tags, ["meat"]) { return .carneMolida }
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

    /// `cold-cut` se busca tal cual. El resto compara palabras, así "ham" no entra en "hamburger"
    /// ni "apple" en "pineapple". El +3 cubre plurales (`milks`, `dairies`).
    private static func hits(_ tags: String, _ keywords: [String]) -> Bool {
        let tokens = tags.split { !$0.isLetter }.map(String.init)
        return keywords.contains { keyword in
            if keyword.contains("-") {
                return tags.contains(keyword)
            }
            return tokens.contains { token in
                token == keyword || (token.hasPrefix(keyword) && token.count <= keyword.count + 3)
            }
        }
    }
}
