//
//  DocumentDataExtractorSwiftUIScannerView.swift
//  ScanbotSDK Examples
//
//  Pure-SwiftUI counterpart of `DocumentDataExtractorViewController`.
//

import SwiftUI
import ScanbotSDK

struct DocumentDataExtractorSwiftUIScannerView: View {

    // The scanner model backing the `SBSDKScannerView` below. It owns the camera session, the
    // scanner configuration and the frame-engine state, and is the SwiftUI equivalent of the
    // Classic UI `SBSDKDocumentDataExtractorViewController`.
    @State private var model: SBSDKDocumentDataExtractorModel = {

        // To create a list of accepted document types.
        var acceptedTypes = [String]()

        // To extract German ID cards.
        acceptedTypes.append(SBSDKDocumentsModelConstants.deIdCardFrontDocumentType)
        acceptedTypes.append(SBSDKDocumentsModelConstants.deIdCardBackDocumentType)

        // Extracts German passports. Front side only.
        acceptedTypes.append(SBSDKDocumentsModelConstants.dePassportDocumentType)

        // Extracts European driver's licenses only. Front and/or back side.
        acceptedTypes.append(SBSDKDocumentsModelConstants.europeanDriverLicenseFrontDocumentType)
        acceptedTypes.append(SBSDKDocumentsModelConstants.europeanDriverLicenseBackDocumentType)

        // To exclude field types from the extraction process.
        let excludedTypes = [SBSDKDocumentsModelConstants.mrzGenderFieldNormalizedName,
                             SBSDKDocumentsModelConstants.mrzIssuingAuthorityFieldNormalizedName,
                             SBSDKDocumentsModelConstants.deIdCardFrontNationalityFieldNormalizedName]

        // Create a configuration instance using the excluded and accepted document types.
        let configuration = SBSDKDocumentDataExtractorConfiguration(
            fieldExcludeList: excludedTypes,
            configurations: [SBSDKDocumentDataExtractorCommonConfiguration(acceptedDocumentTypes: acceptedTypes)]
        )

        // Enable the crops image extraction.
        configuration.returnCrops = true

        let model = try! SBSDKDocumentDataExtractorModel(scannerConfiguration: configuration)

        // Turn the flashlight on/off.
        model.camera.isFlashlightEnabled = false

        // Configure the viewfinder.
        // Enable the view finder
        model.configuration.isViewFinderEnabled = true

        // Configure the view finder colors and line properties.
        model.configuration.viewFinderLineColor = UIColor.red
        model.configuration.viewFinderBackgroundColor = UIColor.red.withAlphaComponent(0.1)
        model.configuration.viewFinderLineWidth = 2
        model.configuration.viewFinderLineCornerRadius = 8

        return model
    }()

    var body: some View {

        // Embed the `SBSDKDocumentDataExtractorModel`-driven camera/detection UI.
        SBSDKScannerView(viewModel: model)
            // Subscribe to the frame engine's result/failure events. This replaces
            // `SBSDKDocumentDataExtractorViewControllerDelegate`.
            .onReceive(model.documentDataExtractorFrameEngine.events) { event in
                switch event {
                case .result(let scan):
                    // Access the document's fields directly by iterating over the document's fields.
                    scan.result.document?.fields.forEach { field in
                        // Print field type name, field text and field confidence to the console.
                        print("\(field.type.name) = \(field.value?.text ?? "") (Confidence: \(field.value?.confidence ?? 0.0)")
                    }

                    // Get the cropped image.
                    let croppedImage = try? scan.result.croppedImage?.toUIImage()

                    // Or get a field by its name.
                    if let nameField = scan.result.document?.field(by: "Surname") {
                        // Access various properties of the field.
                        let fieldTypeName = nameField.type.name
                        let fieldValue = nameField.value?.text
                        let confidence = nameField.value?.confidence
                    }

                case .failure(let error):
                    // Handle the error.
                    print("Error extracting document data: \(error.localizedDescription)")
                }
            }
    }
}

#Preview {
    DocumentDataExtractorSwiftUIScannerView()
}
