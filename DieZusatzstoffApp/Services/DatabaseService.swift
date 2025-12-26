//
//  DatabaseService.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 24.12.25.
//
import Foundation

protocol DatabaseServiceProtocol {
    func fetchProducts() -> [Product]
}

class DatabaseService: DatabaseServiceProtocol {
    func fetchProducts() -> [Product] {
        // 1. Pfad suchen
        guard let url = Bundle.main.url(forResource: "LieferantenDaten", withExtension: "json") else {
            print("❌ FEHLER: Datei 'LieferantenDaten.json' nicht im Projekt-Bundle gefunden!")
            return []
        }
        
        // 2. Daten laden
        do {
            let data = try Data(contentsOf: url)
            
            // 3. Dekodieren
            let products = try JSONDecoder().decode([Product].self, from: data)
            print("✅ ERFOLG: \(products.count) Produkte erfolgreich geladen.")
            return products
            
        } catch let decodingError as DecodingError {
            // Zeigt genau an, welches Feld in der JSON falsch ist
            print("❌ DECODING FEHLER: Deine JSON passt nicht zum Product-Modell.")
            print("Details: \(decodingError)")
            return []
        } catch {
            print("❌ UNBEKANNTER FEHLER: \(error.localizedDescription)")
            return []
        }
    }
}
