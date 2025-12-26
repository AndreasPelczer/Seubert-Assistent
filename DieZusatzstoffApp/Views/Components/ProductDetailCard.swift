//
//  ProductDetailCard.swift
//  Zusatz
//
//  Created by Andreas Pelczer on 24.12.25.
//
import SwiftUI

struct ProductDetailCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. Titelzeile
            Text(product.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 2. Schnell-Symbole (Badges)
            HStack {
                ForEach(product.allergenCodes, id: \.self) { code in
                    Text(code)
                        .font(.caption2).bold()
                        .padding(5)
                        .background(Color.red.opacity(0.2))
                        .clipShape(Circle())
                }
                ForEach(product.additiveCodes, id: \.self) { code in
                    Text("\(code)")
                        .font(.caption2).bold()
                        .padding(5)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            // 3. Detail-Texte mit Klarnamen
            VStack(alignment: .leading, spacing: 6) {
                Text("Allergene:")
                    .font(.caption).bold()
                
                // Nutzt den Mapper für Klarnamen (z.B. a -> Ei)
                Text(product.allergenCodes.compactMap { code in
                    if let name = AllergenMapper.all[code] {
                        return "\(code) (\(name))"
                    }
                    return code
                }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(.red)
                
                Text("Zusatzstoffe:")
                    .font(.caption).bold()
                
                // Nutzt den Mapper für Zusatzstoffe (z.B. 1 -> Konservierungsstoffe)
                Text(product.additiveCodes.compactMap { code in
                    if let name = AdditiveMapper.all[code] {
                        return "\(code) (\(name))"
                    }
                    return String(code)
                }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(.orange)
            }
        }
        // HIER liegen die wichtigen Layout-Befehle für die Karte selbst
        .padding()
        .frame(width: 280) // Etwas breiter für die Klarnamen
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
