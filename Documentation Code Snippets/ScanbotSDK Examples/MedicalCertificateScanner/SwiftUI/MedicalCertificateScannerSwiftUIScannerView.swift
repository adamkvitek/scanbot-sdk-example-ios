//
//  MedicalCertificateScannerSwiftUIScannerView.swift
//  ScanbotSDK Examples
//
//  Pure-SwiftUI counterpart of `MedicalCertificateScannerViewController`.
//

import SwiftUI
import ScanbotSDK

struct MedicalCertificateScannerSwiftUIScannerView: View {

    // The scanner model backing the `SBSDKScannerView` below. It owns the camera session, the
    // scanner configuration and the frame-engine state, and is the SwiftUI equivalent of the
    // Classic UI `SBSDKMedicalCertificateScannerViewController`.
    @State private var model: SBSDKMedicalCertificateScannerModel = {

        // Create an instance of `SBSDKMedicalCertificateScanningParameters` with default values.
        let scanningParameters = SBSDKMedicalCertificateScanningParameters()

        // Enable the medical certificate image extraction.
        scanningParameters.extractCroppedImage = true

        // Customize the parameters as needed.
        scanningParameters.shouldCropDocument = true
        scanningParameters.recognizePatientInfoBox = true
        scanningParameters.recognizeBarcode = true
        scanningParameters.preprocessInput = false

        return try! SBSDKMedicalCertificateScannerModel(scanningParameters: scanningParameters)
    }()

    var body: some View {

        // Embed the `SBSDKMedicalCertificateScannerModel`-driven camera/detection UI.
        SBSDKScannerView(viewModel: model)
            // Subscribe to the frame engine's result/failure events. This replaces
            // `SBSDKMedicalCertificateScannerViewControllerDelegate`.
            .onReceive(model.medicalCertificateFrameEngine.events) { event in
                switch event {
                case .result(.snap(let result)), .result(.sample(let result)):
                    // Process the scanned result.

                    // Get the cropped image.
                    let croppedImage = try? result.croppedImage?.toUIImage()

                case .failure(let error):
                    // Handle the error.
                    print("Error scanning Medical certificate: \(error.localizedDescription)")
                }
            }
    }
}

#Preview {
    MedicalCertificateScannerSwiftUIScannerView()
}
