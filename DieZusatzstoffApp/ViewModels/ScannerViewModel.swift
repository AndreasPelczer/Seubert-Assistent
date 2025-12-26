import Foundation
import SwiftUI

class ScannerViewModel: ObservableObject {
    @Published var allProducts: [Product] = []
    @Published var detectedProducts: [Product] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Product.ProductCategory? = nil
    
    private let dataImporter = DataImporter()
    private let offService = OpenFoodFactsService()

    init() {
        loadRealData()
    }

    func loadRealData() {
        self.allProducts = dataImporter.loadProductsFromBundle()
        print("DEBUG: \(allProducts.count) Produkte aus CSV geladen.")
    }

    func processText(_ text: String, completion: @escaping () -> Void) {        // 1. Alles klein schreiben und ALLES entfernen, was kein Buchstabe oder Zahl ist
        let cleanedText = text.lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("DEBUG: Kamera-Roh-Text: '\(text)'")
        print("DEBUG: Bereinigter Text: '\(cleanedText)'")

        for product in allProducts {
            let productName = product.name.lowercased().trimmingCharacters(in: .whitespaces)
            let productId = product.id.lowercased().trimmingCharacters(in: .whitespaces)
            
            // Prüfen, ob der Name oder die ID im erkannten Text vorkommen
            if cleanedText.contains(productId) || cleanedText.contains(productName) {
                DispatchQueue.main.async {
                    if !self.detectedProducts.contains(where: { $0.id == product.id }) {
                        self.detectedProducts.append(product)
                        print("DEBUG: Treffer gefunden: \(product.name)")
                    }
                }
                return // Ersten Treffer sofort anzeigen
            }
        }
        
        // 2. Barcode-Logik (falls kein Text-Treffer)
        // ... dein restlicher Barcode-Code ...
        completion()
        }
    // Hilfsfunktion für den externen Aufruf (NUR EINMAL VORHANDEN)
    func searchExternal(barcode: String) {
        print("DEBUG: Starte API-Abfrage für \(barcode)...")
        
        offService.fetchProduct(barcode: barcode) { [weak self] externalProduct in
            // WICHTIG: Wir müssen zurück auf den Main-Thread, um die UI zu ändern
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let product = externalProduct {
                    print("DEBUG: Produkt erhalten: \(product.name)")
                    
                    // Prüfen, ob wir es schon haben
                    if !self.detectedProducts.contains(where: { $0.id == product.id }) {
                        self.detectedProducts.append(product)
                        print("DEBUG: Produkt zur Liste hinzugefügt. Neue Anzahl: \(self.detectedProducts.count)")
                    } else {
                        print("DEBUG: Produkt war schon in der Liste.")
                    }
                } else {
                    print("DEBUG: API hat für diesen Barcode kein Produkt gefunden.")
                }
            }
        }
    }

    // --- FILTER-LOGIK FÜR DIE LISTE ---
    var filteredProducts: [Product] {
        let baseList: [Product]
        
        if !searchText.isEmpty {
            // 1. Manuelle Suche geht immer vor
            baseList = allProducts.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.id.contains(searchText)
            }
        } else if !detectedProducts.isEmpty {
            // 2. Wenn Scans da sind, zeigen wir diese (inkl. der manuellen Suche/Kategorie)
            baseList = detectedProducts
        } else {
            // 3. Wenn die Liste leer ist, zeige alles (Katalog-Modus)
            baseList = allProducts
        }
        
        // Kategoriefilter anwenden
        if let category = selectedCategory {
            return baseList.filter { $0.category == category }
        }
        
        return baseList
    }

    func resetResults() {
        detectedProducts = []
        searchText = ""
        selectedCategory = nil
    }
    func testExternalSearch() {
        // Beispiel Barcode für Nutella (sollte immer in der DB sein)
        let testBarcode = "3017620422003"
        print("DEBUG: Test-Suche gestartet...")
        searchExternal(barcode: testBarcode)
    }
}
