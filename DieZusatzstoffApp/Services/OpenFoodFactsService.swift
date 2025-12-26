import Foundation

// Das Modell für die Antwort von Open Food Facts
struct OFFResponse: Codable {
    let product: OFFProduct?
    let status: Int
}

struct OFFProduct: Codable {
    let productName: String? // CamelCase verwenden!
    let allergens: String?
    let imageFrontUrl: String?
    let additivesTags: [String]? // Wichtig für die Zusatzstoffe
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case allergens
        case imageFrontUrl = "image_front_url"
        case additivesTags = "additives_tags"
    }
}

class OpenFoodFactsService {
    
    func fetchProduct(barcode: String, completion: @escaping (Product?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(OFFResponse.self, from: data)
                
                if let offProduct = decodedResponse.product, decodedResponse.status == 1 {
                    
                    // Wir erstellen das Product-Objekt passend zum neuen Modell
                    let foundProduct = Product(
                        id: barcode,
                        name: offProduct.productName ?? "Unbekanntes Produkt",
                        category: .meat,
                        allergenCodes: self.extractAllergens(from: offProduct),
                        additiveCodes: self.extractAdditives(from: offProduct),
                        supplier: "Extern (Open Food Facts)",
                        rawInstruction: ""
                    )
                    
                    DispatchQueue.main.async {
                        completion(foundProduct)
                    }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            } catch {
                print("Decoding-Fehler: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    // Behebt den Fehler: extractAllergens
    private func extractAllergens(from offProduct: OFFProduct) -> [String] {
        guard let allergens = offProduct.allergens, !allergens.isEmpty else { return [] }
        // Filtert "en:gluten" zu "A" etc., falls möglich, oder gibt Namen zurück
        return allergens.components(separatedBy: ",")
            .map { $0.replacingOccurrences(of: "en:", with: "").trimmingCharacters(in: .whitespaces).capitalized }
    }
    
    // Behebt den Fehler: extractAdditives
    private func extractAdditives(from offProduct: OFFProduct) -> [Int] {
        guard let tags = offProduct.additivesTags else { return [] }
        // OFF gibt E-Nummern als "en:e300" zurück. Wir versuchen die Zahl zu extrahieren.
        return tags.compactMap { tag in
            let numberString = tag.replacingOccurrences(of: "en:e", with: "")
            return Int(numberString)
        }
    }
}
