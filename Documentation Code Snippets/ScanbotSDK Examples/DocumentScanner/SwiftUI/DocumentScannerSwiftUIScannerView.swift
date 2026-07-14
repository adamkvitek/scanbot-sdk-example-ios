//
//  DocumentScannerSwiftUIScannerView.swift
//  ScanbotSDK Examples
//
//  Pure-SwiftUI counterpart of `DocumentScannerViewController`.
//

import SwiftUI
import ScanbotSDK

struct DocumentScannerSwiftUIScannerView: View {

    // The scanner model backing the `SBSDKScannerView` below. It owns the camera session, the
    // scanner configuration and the frame-engine state, and is the SwiftUI equivalent of the
    // Classic UI `SBSDKDocumentScannerViewController`.
    @State private var model = SBSDKDocumentScannerModel()

    // The last scanned result, shown as a simple text overlay.
    @State private var resultText: String?

    var body: some View {
        ZStack(alignment: .bottom) {

            // Embed the `SBSDKDocumentScannerModel`-driven camera/detection UI.
            SBSDKScannerView(viewModel: model)

            if let resultText {
                Text(resultText)
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
            }
        }
        // Subscribe to the frame engine's result/failure events. This replaces
        // `SBSDKDocumentScannerViewControllerDelegate`.
        .onReceive(model.documentFrameEngine.events) { event in
            switch event {
            case .result(.snap(let snap)):
                // Process the detected document.

                // Convert ImageRef to UIImage if needed.
                let documentUIImage = try? snap.documentImage.toUIImage()
                resultText = "Auto-snapped: \(snap.autoSnapped ? "Yes" : "No")"

            case .result(.sample):
                // A per-frame sample without a completed snap; nothing to do here.
                break

            case .failure(let error):
                // Handle the error.
                print("Error scanning document: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    DocumentScannerSwiftUIScannerView()
}
