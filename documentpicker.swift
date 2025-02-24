import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var resumeText: String
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            if let text = extractText(from: url) {
                DispatchQueue.main.async {
                    self.parent.resumeText = text
                }
            }
        }
        
        func extractText(from url: URL) -> String? {
            guard let pdf = PDFDocument(url: url) else {
                print("Failed to load PDF")
                return "Error: Failed to load PDF."
            }
            
            var extractedText = ""
            
            // Iterate through all pages to extract text
            for pageIndex in 0..<pdf.pageCount {
                if let page = pdf.page(at: pageIndex), let text = page.string {
                    extractedText += text + "\n"
                }
            }
            
            // If no text is found, return a message indicating so
            if extractedText.isEmpty {
                return "Error: No text found in the PDF."
            }
            
            return extractedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Allowing only PDF files to be selected
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct ContentView: View {
    @State private var resumeText = ""
    
    var body: some View {
        VStack {
            Text(resumeText)
                .padding()
            
            // Add the DocumentPicker to the UI
            DocumentPicker(resumeText: $resumeText)
                .frame(height: 50)
                .padding()
        }
        .padding()
    }
}

@main
struct PDFTextExtractorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
