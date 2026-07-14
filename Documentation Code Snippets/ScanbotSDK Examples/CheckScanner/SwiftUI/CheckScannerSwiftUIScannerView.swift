//
//  CheckScannerSwiftUIScannerView.swift
//  ScanbotSDK Examples
//
//  Pure-SwiftUI counterpart of `CheckScannerViewController`.
//

import SwiftUI
import ScanbotSDK

struct CheckScannerSwiftUIScannerView: View {

    // The label to present the scanning status updates.
    @State private var statusText: String = ""

    // The scanner model backing the `SBSDKScannerView` below. It owns the camera session, the
    // scanner configuration and the frame-engine state, and is the SwiftUI equivalent of the
    // Classic UI `SBSDKCheckScannerViewController`.
    @State private var model: SBSDKCheckScannerModel = {

        // Create a configuration with `detectAndCropDocument` to extract the check image.
        let configuration = SBSDKCheckScannerConfiguration(documentDetectionMode: .detectAndCropDocument)

        let model = try! SBSDKCheckScannerModel(scannerConfiguration: configuration)

        // Customize the default accepted check types as needed.
        // For this example we will use the following types of check.
        model.checkConfiguration.acceptedCheckTypes = [.usaCheck, .uaeCheck, .fraCheck, .isrCheck,
                                                        .kwtCheck, .ausCheck, .indCheck, .canCheck]
        return model
    }()

    var body: some View {
        ZStack(alignment: .top) {

            // Embed the `SBSDKCheckScannerModel`-driven camera/detection UI.
            SBSDKScannerView(viewModel: model)

            Text(statusText)
                .padding()
                .background(.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
        }
        // Subscribe to the frame engine's result/failure events. This replaces
        // `SBSDKCheckScannerViewControllerDelegate`.
        .onReceive(model.checkFrameEngine.events) { event in
            switch event {
            case .result(.snap(let result)), .result(.sample(let result)):
                // Process the scanned result.

                // Get the cropped image.
                let croppedImage = try? result.croppedImage?.toUIImage()

            case .failure(let error):
                // Handle the error.
                print("Error scanning check: \(error.localizedDescription)")
            }
        }
        // Subscribe to state changes, mirroring the `didChangeState` delegate callback.
        .onReceive(model.checkFrameEngine.publisher(for: \.state, options: [.initial, .new])) { state in

            // Update status label according to status
            switch state {
            case .searching:
                statusText = "Looking for the check"
            case .capturing:
                statusText = "Capturing the check"
            case .energySaving:
                statusText = "Energy saving mode"
            case .paused:
                statusText = "Recognition paused"
            @unknown default:
                fatalError()
            }
        }
    }
}

#Preview {
    CheckScannerSwiftUIScannerView()
}
