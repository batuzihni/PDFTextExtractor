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
                return nil
            }
            var extractedText = ""
            for pageIndex in 0..<pdf.pageCount {
                if let page = pdf.page(at: pageIndex), let text = page.string {
                    extractedText += text + "\n"
                }
            }
            if extractedText.isEmpty {
                print("No text found in the PDF.")
            }
            return extractedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}
