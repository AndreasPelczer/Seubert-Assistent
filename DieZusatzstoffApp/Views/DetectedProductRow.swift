import SwiftUI

struct DetectedProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 15) {
            // 1. Farbiger Balken & Icon
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(product.category.color)
                    .frame(width: 4)
                
                Text(product.category.icon)
                    .font(.system(size: 10))
                    .padding(.top, 4)
            }
            .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(product.id)
                        .font(.caption.monospaced())
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Labels
                    HStack(spacing: 4) {
                        if product.supplier.contains("Extern") {
                            statusLabel(text: "EXTERN", color: .gray)
                        }
                        
                        if product.allergenCodes.isEmpty {
                            statusLabel(text: "VEGAN", color: .green)
                        }
                    }
                }
                
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    // Allergene (Orange Kreise)
                    HStack(spacing: 4) {
                        ForEach(product.allergenCodes, id: \.self) { code in
                            Text(code.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 18, height: 18)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.orange.opacity(0.2), lineWidth: 1))
                        }
                    }
                    
                    // NEU: Zusatzstoffe (Farbige Badges)
                    if !product.additiveCodes.isEmpty {
                        Text("|")
                            .foregroundColor(.secondary.opacity(0.3))
                            .padding(.horizontal, 2)
                        
                        HStack(spacing: 3) {
                            ForEach(product.additiveCodes, id: \.self) { code in
                                Text("\(code)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.purple.opacity(0.8)) // Lila unterscheidet sich gut von Orange
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Kerntemperatur
                    if let temp = product.cookingInstruction?.coreTemp, temp != "--" {
                        Label("\(temp)°C", systemImage: "thermometer.medium")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Hilfsfunktion für die kleinen Status-Labels oben rechts
    private func statusLabel(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .bold))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

// Deine Extension (korrekt außerhalb)
extension Product.ProductCategory {
    var icon: String {
        switch self {
        case .meat: return "🥩"
        case .poultry: return "🍗"
        case .veggie: return "🥕"
        case .fish: return "🐟"
        case .dessert: return "🍰"
        case .appetizer: return "🍡"
        }
    }
}
