import SwiftUI
import Vision
import UIKit

struct CameraView: UIViewControllerRepresentable {
    var onTextRecognized: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        // Erlaubt dem User zu fokussieren
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextRecognized: onTextRecognized)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onTextRecognized: (String) -> Void
        
        init(onTextRecognized: @escaping (String) -> Void) {
            self.onTextRecognized = onTextRecognized
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage,
                  let cgImage = image.cgImage else {
                picker.dismiss(animated: true)
                return
            }
            
            // Text-Erkennungs-Request konfigurieren
            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                // Alle erkannten Textzeilen sammeln
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: "\n")
                
                DispatchQueue.main.async {
                    picker.dismiss(animated: true) {
                        self.onTextRecognized(fullText)
                    }
                }
            }
            
            // WICHTIG FÜR IPHONE 8:
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false // Deaktivieren für Barcodes/Zahlen
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Fehler bei der Texterkennung: \(error)")
                    DispatchQueue.main.async {
                        picker.dismiss(animated: true)
                    }
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
