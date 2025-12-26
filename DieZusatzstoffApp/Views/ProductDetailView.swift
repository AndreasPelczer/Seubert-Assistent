import SwiftUI
import AVFoundation

struct ProductDetailView: View {
    let product: Product
    
    @State private var remainingTime = 0
    @State private var timerActive = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if let instruction = product.cookingInstruction {
                    temperatureBadge(instruction: instruction)
                }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(product.name)
                            .font(.title2.bold())
                        Text("Art.-Nr. \(product.id) | \(product.supplier)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if !product.rawInstruction.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("ZUBEREITUNG", systemImage: "chefhat.fill")
                                .font(.caption.bold())
                                .foregroundColor(product.category.color)
                            
                            Text(product.rawInstruction)
                                .font(.system(.body, design: .serif))
                                .italic()
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(product.category.color.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                    allergenSection
                    additiveSection
                }
                .padding(.horizontal)

                if remainingTime > 0 {
                    timerSection
                }
            }
            .padding(.bottom, 30)
        }
        .onAppear { setupView() }
        .onDisappear { cleanupView() }
    }

    private func temperatureBadge(instruction: Product.ParsedInstruction) -> some View {
        // 1. Logik-Bereich (AUSSERHALB der View-Hierarchie)
        let methodText = instruction.method.lowercased()
        let typeLabel: String
        
        if methodText.contains("pfanne") || methodText.contains("backen") || methodText.contains("braten") {
            typeLabel = "PFANNE"
        } else if methodText.contains("friteuse") || methodText.contains("frittieren") {
            typeLabel = "FRITEUSE"
        } else if methodText.contains("grill") {
            typeLabel = "GRILL"
        } else {
            typeLabel = "OFEN/Kombiedämpfer"
        }
        
        let isMainCourse = [.meat, .poultry, .fish].contains(product.category)

        // 2. View-Bereich
        return VStack(spacing: 15) {
            if isMainCourse {
                HStack(spacing: 0) {
                    VStack(spacing: 5) {
                        Text(instruction.cookingTemp != nil ? typeLabel : "GARTEMP")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(instruction.cookingTemp ?? instruction.coreTemp ?? "--")°C")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    VStack(spacing: 5) {
                        Text("KERN")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(instruction.coreTemp ?? "--")°C")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Image(systemName: product.category == .dessert ? "snowflake" : "info.circle")
                    .font(.system(size: 40))
            }

            Text(instruction.method)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .foregroundColor(.white)
        .padding(.vertical, 25)
        .background(RoundedRectangle(cornerRadius: 25).fill(product.category.color.gradient))
        .padding(.horizontal)
    }

    private var allergenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Allergene", systemImage: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.headline)
            
            if product.allergenCodes.isEmpty {
                Text("Keine").foregroundColor(.secondary)
            } else {
                ForEach(product.allergenCodes, id: \.self) { code in
                    HStack {
                        Text(code).bold().frame(width: 35, alignment: .leading)
                        Text(Product.allergenLookup[code.uppercased()] ?? "Unbekannt")
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }

    private var additiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Zusatzstoffe", systemImage: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.headline)
            
            if product.additiveCodes.isEmpty {
                Text("Keine").foregroundColor(.secondary)
            } else {
                ForEach(product.additiveCodes, id: \.self) { code in
                    HStack {
                        Text("\(code)").bold().frame(width: 35, alignment: .leading)
                        Text(Product.additiveLookup[code] ?? "Unbekannt")
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }

    private var timerSection: some View {
        VStack(spacing: 15) {
            Text("Timer für \(product.cookingInstruction?.duration ?? "Zubereitung")")
            Button(action: toggleTimer) {
                Label(timerActive ? timeString(from: remainingTime) : "Timer starten", systemImage: timerActive ? "stop.fill" : "play.fill")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(timerActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .padding(.horizontal)
    }

    // --- Logik ---
    private func setupView() {
        if let duration = product.cookingInstruction?.duration {
            self.remainingTime = calculateSeconds(from: duration)
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func cleanupView() {
        timer?.invalidate()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func calculateSeconds(from duration: String) -> Int {
        // Diese Logik extrahiert die erste Zahl aus einem String wie "90-120 Min" oder "15 Min"
        let components = duration.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let numbers = components.filter { !$0.isEmpty }
        
        if let firstDuration = numbers.first, let minutes = Int(firstDuration) {
            return minutes * 60
        }
        return 0
    }
    private func toggleTimer() {
        if timerActive {
            timer?.invalidate()
            timerActive = false
        } else {
            guard remainingTime > 0 else { return }
            timerActive = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 { remainingTime -= 1 } else { playAlarm() }
            }
        }
    }

    private func playAlarm() {
        timer?.invalidate()
        timerActive = false
        AudioServicesPlaySystemSound(1005)
    }

    private func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
