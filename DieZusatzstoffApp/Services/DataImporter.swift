import Foundation

class DataImporter {
    
    func loadProductsFromBundle() -> [Product] {
        guard let path = Bundle.main.path(forResource: "Produkte", ofType: "csv") else {
            print("FEHLER: Datei 'Produkte.csv' nicht im Projekt gefunden!")
            return []
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return parseCatalogText(content)
        } catch {
            print("FEHLER beim Lesen: \(error)")
            return []
        }
    }
    
    func parseCatalogText(_ text: String) -> [Product] {
        var foundProducts: [Product] = []
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty { continue }
            
            // Überspringe Kopfzeile
            if index == 0 && (trimmedLine.contains("ArtNr") || trimmedLine.contains("Name")) {
                continue
            }
            
            if let product = parseSeubertLine(trimmedLine) {
                foundProducts.append(product)
            }
        }
        return foundProducts
    }
    
    private func parseSeubertLine(_ line: String) -> Product? {
        let columns = line.components(separatedBy: ";")
        
        // Wir brauchen mindestens ID und Name
        guard columns.count >= 2 else { return nil }
        
        let artNr = columns[0].trimmingCharacters(in: .whitespaces)
        let name = columns[1].trimmingCharacters(in: .whitespaces)
        
        // 1. Kategorie bestimmen
        let category = determineCategory(from: name, artNr: artNr)
        
        // 2. Allergene (Spalte 4, Index 3)
        let allergenCodes: [String]
        if columns.count > 3 {
            allergenCodes = columns[3].components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
                .filter { !$0.isEmpty && $0 != "-" }
        } else {
            allergenCodes = []
        }
        
        // 3. Zusatzstoffe (Spalte 5, Index 4)
        // Extrahiert Zahlen wie "1,2,8" und wandelt sie in eine Liste von Ints um
        let additiveCodes: [Int]
        if columns.count > 4 {
            additiveCodes = columns[4].components(separatedBy: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        } else {
            additiveCodes = []
        }
        
        // 4. Lieferant (Spalte 6, Index 5)
        let supplier = columns.count > 5 ? columns[5].trimmingCharacters(in: .whitespaces) : "Seubert"
        
        // 5. Zubereitungstext (Spalte 7, Index 6)
        let rawInstruction = columns.count > 6 ? columns[6].trimmingCharacters(in: .whitespaces) : ""

        return Product(
            id: artNr,
            name: name,
            category: category,
            allergenCodes: allergenCodes,
            additiveCodes: additiveCodes,
            supplier: supplier,
            rawInstruction: rawInstruction
        )
    }

    private func determineCategory(from name: String, artNr: String) -> Product.ProductCategory {
        let lowerName = name.lowercased()
        
        if artNr.hasPrefix("22") || lowerName.contains("apfel") || lowerName.contains("küchle") {
            return .dessert
        }
        
        if (artNr.hasPrefix("2") && !artNr.hasPrefix("22")) || lowerName.contains("hähnchen") || lowerName.contains("pute") {
            return .poultry
        }
        
        if artNr.hasPrefix("18") || lowerName.contains("fisch") || lowerName.contains("lachs") {
            return .fish
        }
        
        if artNr.hasPrefix("19") || lowerName.contains("zucchini") || lowerName.contains("linse") {
            return .veggie
        }
        
        return .meat
    }
}
