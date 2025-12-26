import SwiftUI

struct MainScannerView: View {
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showCamera = false
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Nur zeigen, wenn wir NICHT auf dem Dashboard sind
                if !viewModel.searchText.isEmpty || !viewModel.detectedProducts.isEmpty {
                    headerView
                    categoryPicker
                }
                
                contentView
                
                // Den unteren Button nur zeigen, wenn wir bereits in der Liste sind
                if !viewModel.searchText.isEmpty || !viewModel.detectedProducts.isEmpty {
                    scanButton
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Seubert Assistent")
            .navigationBarTitleDisplayMode(.inline)
            // Die Searchbar nur einblenden, wenn wir sie brauchen (optional)
            .searchable(text: $viewModel.searchText, prompt: "Produkt suchen...")
            // Den Internet Test in das Menü oben rechts verschieben
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.testExternalSearch()
                    } label: {
                        Image(systemName: "network")
                            .font(.caption)
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { recognizedText in
                showCamera = false
                processScannedText(recognizedText)
            }
        }
    }

    // --- Unter-Views für bessere Übersicht ---

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.searchText.isEmpty ? "\(viewModel.detectedProducts.count) Scans" : "Suche")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if !viewModel.detectedProducts.isEmpty {
                Button("Leeren") { viewModel.resetResults() }
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "Alle", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                
                ForEach(Product.ProductCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        activeColor: category.color
                    ) {
                        // Das hier ist die "action", sie steht hinter der Klammer
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isProcessing {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Text("Analysiere...").padding()
                Spacer()
            }
        } else if viewModel.searchText.isEmpty && viewModel.detectedProducts.isEmpty {
            // --- DAS NEUE, ÜBERSICHTLICHE DASHBOARD ---
            VStack(spacing: 25) {
                Spacer()
                
                // Zentrales Erkennungs-Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }

                VStack(spacing: 8) {
                    Text("Bereit zum Scannen")
                        .font(.title2.bold())
                    Text("Halten Sie die Kamera auf eine Speisekarte,ein Etikett/Barcode\noder suchen Sie im Katalog.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                // Große, klare Aktions-Karten
                VStack(spacing: 16) {
                    // Haupt-Aktion: Scanner
                    Button(action: { showCamera = true }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Scan starten")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }

                    // Neben-Aktion: Katalog-Info
                    HStack {
                        Image(systemName: "info.circle")
                        Text("\(viewModel.allProducts.count) Produkte im Katalog")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        } else {
            // --- DIE ÜBERSICHTLICHE ERGEBNISLISTE ---
            List {
                Section(header: Text(viewModel.searchText.isEmpty ? "Gescannte Produkte" : "Suchergebnisse")) {
                    ForEach(viewModel.filteredProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            DetectedProductRow(product: product)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }

    private var scanButton: some View {
        Button(action: { showCamera = true }) {
            Label("SCAN STARTEN", systemImage: "camera.viewfinder")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
        }
    }

    private func processScannedText(_ text: String) {
        guard !text.isEmpty else { return }
        
        isProcessing = true
        viewModel.processText(text, completion: <#() -> Void#>)
        
        // 1.0 Sekunde reicht meistens völlig aus, um den "Analysiere"-Effekt zu zeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
            
            // Kleiner Trick: Wenn nichts gefunden wurde, gib eine Vibration aus
            if viewModel.detectedProducts.isEmpty {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
}
