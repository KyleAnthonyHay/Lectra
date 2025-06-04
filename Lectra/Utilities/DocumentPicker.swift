import SwiftUI
import UniformTypeIdentifiers

class DocumentPicker: NSObject, UIDocumentPickerDelegate {
    var completion: (URL) -> Void
    
    init(completion: @escaping (URL) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        completion(url)
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    
    func makeCoordinator() -> DocumentPicker {
        return DocumentPicker(completion: completion)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.audio, .mpeg4Audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
} 