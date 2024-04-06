//
//  DocumentPicker.swift
//  BlindingFX
//
//  Created by Ravi Heyne on 05/04/24.
//

import SwiftUI
import UniformTypeIdentifiers

//Extra documentation to explain more obscure functions

// Struct representing a document picker to allow the user to pick an audio file
struct DocumentPicker: UIViewControllerRepresentable {
    // Access the environment's presentation mode to control dismissal of the view
    @Environment(\.presentationMode) var presentationMode
    // A completion handler for when a file is picked
    @Binding var completionHandler: ((URL) -> Void)?
    // A binding to a URL representing the chosen audio file
    @Binding var audioFileURL: URL?

    // Creates a coordinator for managing the document picker's delegate callbacks
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    // Creates the view controller that represents the document picker
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        // Define supported audio file types
        let audioTypes: [UTType] = [UTType.mp3, UTType.wav]
        // Create a document picker with supported file types
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: audioTypes, asCopy: true)
        // Set the coordinator as the document picker's delegate
        picker.delegate = context.coordinator
        return picker
    }

    // Updates the view controller - no action needed here
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }

    // class for coordinating the document picker's delegate callbacks
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        // reference to the DocumentPicker instance
        var parent: DocumentPicker

        // Initialize the coordinator with a reference to the parent document picker
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        // Called when the user picks a document
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Set the parent's audioFileURL to the first URL in the array
            parent.audioFileURL = urls.first
            // Dismiss the document picker
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Called when the user cancels the document picker
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Dismiss the document picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
