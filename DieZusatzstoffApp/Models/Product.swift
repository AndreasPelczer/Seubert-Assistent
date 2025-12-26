import Foundation
import SwiftUI

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let category: ProductCategory
    let allergenCodes: [String]
    let additiveCodes: [Int]
    let supplier: String
    let rawInstruction: String
    
    enum ProductCategory: String, CaseIterable, Codable {
        case appetizer, meat, fish, poultry, veggie, dessert
    }

    struct ParsedInstruction {
        let cookingTemp: String?
        let coreTemp: String?
        let method: String
        let duration: String?
    }

    var cookingInstruction: ParsedInstruction? {
        parseInstruction(rawInstruction)
    }

    private func parseInstruction(_ text: String) -> ParsedInstruction? {
        if text.isEmpty { return nil }

        var temp: String? = nil
        var core: String? = nil
        var dur: String? = nil

        // Temperatur finden (Regex für Zahlen vor °C)
        if let range = text.range(of: #"\d+(?=\s?°C)"#, options: .regularExpression) {
            temp = String(text[range])
        }
        
        // Kerntemperatur finden (Regex für KT + Zahl)
        if let range = text.range(of: #"(?<=KT\s?)\d+"#, options: .regularExpression) {
            core = String(text[range])
        }
        
        // Dauer finden (Regex für Minuten)
        if let range = text.range(of: #"\d+(-?\d+)?(?=\s?Min)"#, options: .regularExpression) {
            dur = String(text[range]) + " Min"
        } else if text.contains("Min") {
            dur = "Zeit n.A."
        }

        let isMainCourse = [.meat, .poultry, .fish].contains(self.category)
        
        if isMainCourse || !text.isEmpty {
            return ParsedInstruction(
                cookingTemp: temp,
                coreTemp: core,
                method: text,
                duration: dur
            )
        }
        return nil
    }
} // <--- Ende der Struct Product

// MARK: - Extensions (MÜSSEN außerhalb der Struct stehen)
extension Product.ProductCategory {
    var color: Color {
        switch self {
        case .meat: return .red
        case .poultry: return .orange
        case .veggie: return .green
        case .fish: return .blue
        case .dessert: return .purple
        case .appetizer: return .cyan
        }
    }
}

extension Product {
    static let allergenLookup: [String: String] = [
        "A": "Gluten", "C": "Eier", "D": "Fisch", "F": "Soja",
        "G": "Milch", "I": "Sellerie", "J": "Senf", "K": "Sesam",
        "L": "Sulfite", "M": "Lupinen", "N": "Weichtiere"
    ]
    
    static let additiveLookup: [Int: String] = [
        1: "mit Farbstoff", 2: "mit Konservierungsstoff", 3: "Antioxidationsmittel",
        4: "Geschmacksverstärker", 8: "mit Phosphat"
    ]
}
