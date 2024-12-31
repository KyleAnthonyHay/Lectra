import Foundation
import UIKit
import MarkdownUI
import SwiftUI

func saveMarkdownAsPDF(markdown: String) {
    let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // Standard A4 size
    let pdfData = pdfRenderer.pdfData { context in
        context.beginPage()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: NSParagraphStyle.default
        ]
        
        let attributedString = NSAttributedString(string: markdown, attributes: attributes)
        attributedString.draw(in: CGRect(x: 20, y: 20, width: 572, height: 752)) // With margins
    }
    
    // Set up the Transcriptions directory
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let transcriptionsDirectory = documentsURL.appendingPathComponent("Transcriptions")

    // Ensure the Transcriptions directory exists
    if !fileManager.fileExists(atPath: transcriptionsDirectory.path) {
        do {
            try fileManager.createDirectory(at: transcriptionsDirectory, withIntermediateDirectories: true, attributes: nil)
            print("Transcriptions directory created at \(transcriptionsDirectory.path)")
        } catch {
            print("Failed to create Transcriptions directory: \(error.localizedDescription)")
            return
        }
    }

    // Define the file path for the PDF
    let pdfURL = transcriptionsDirectory.appendingPathComponent("Notes.pdf")
    
    do {
        try pdfData.write(to: pdfURL)
        print("PDF saved to \(pdfURL)")
    } catch {
        print("Failed to save PDF: \(error.localizedDescription)")
    }
}
