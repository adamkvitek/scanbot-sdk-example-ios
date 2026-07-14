//
//  TextPatternScannerSwiftUIScannerView.swift
//  ScanbotSDK Examples
//
//  Pure-SwiftUI counterpart of `TextPatternScannerViewController`.
//

import SwiftUI
import ScanbotSDK

struct TextPatternScannerSwiftUIScannerView: View {

    // The scanner model backing the `SBSDKScannerView` below. It owns the camera session, the
    // scanner configuration and the frame-engine state, and is the SwiftUI equivalent of the
    // Classic UI `SBSDKTextPatternScannerViewController`.
    @State private var model: SBSDKTextPatternScannerModel = {

        // Create the default `SBSDKTextPatternScannerConfiguration` object.
        let configuration = SBSDKTextPatternScannerConfiguration()

        return try! SBSDKTextPatternScannerModel(scannerConfiguration: configuration)
    }()

    var body: some View {

        // Embed the `SBSDKTextPatternScannerModel`-driven camera/detection UI.
        SBSDKScannerView(viewModel: model)
            // Subscribe to the frame engine's result/failure events. This replaces
            // `SBSDKTextPatternScannerViewControllerDelegate`.
            .onReceive(model.textPatternFrameEngine.events) { event in
                switch event {
                case .result(let result):
                    // Process the scanned result.
                    break

                case .failure(let error):
                    // Handle the error.
                    print("Error scanning text pattern: \(error.localizedDescription)")
                }
            }
    }
}

#Preview {
    TextPatternScannerSwiftUIScannerView()
}
