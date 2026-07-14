//
//  ClassicUIScannerViewController.swift
//  ScanbotSDK Examples
//
//  Created by Sebastian Husche on 11.11.24.
//

import Foundation
import ScanbotSDK

class ClassicUIScannerViewController: UIViewController {

    // The instance of the ClassicUI scanner view controller. `SBSDKDocumentScannerViewController` is used
    // here as an example, but this code applies to all `SBSDKBaseScannerViewController`-derived ClassicUI
    // scanner view controllers.
    var scannerViewController: SBSDKDocumentScannerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the ClassicUI scanner view controller instance. `SBSDKDocumentScannerViewController`
        // is used here as an example, but this code applies to all `SBSDKBaseScannerViewController`-
        // derived ClassicUI scanner view controllers.
        self.scannerViewController = SBSDKDocumentScannerViewController(parentViewController: self,
                                                                        parentView: self.view,
                                                                        delegate: self)

        // The scanner view controller exposes its state through its `model` (an
        // `SBSDKBaseScannerModel`-derived observable object) and the underlying `model.camera`.
        // Set properties on either directly to configure the scanner at runtime. Both are
        // KVO-observable, so you can also react to their changes from Swift, SwiftUI and Obj-C.

        self.applyGeneralConfiguration()
        self.applyZoomConfiguration()
        self.applyEnergyConfiguration()
        self.applyViewFinderConfiguration()
    }

    func applyGeneralConfiguration() {

        // General scanner behavior lives on the model's configuration. Timings, motion and video
        // settings are set directly on it — no configuration snapshot to read/modify/write.
        scannerViewController.model.configuration.minimumTimeWithoutDeviceMotionBeforeDetection = 0.5

        // Camera-session-level settings live on `model.camera`. Setting the keep-alive timeout
        // to `.greatestFiniteMagnitude` keeps the camera session alive until the model is
        // deallocated.
        scannerViewController.model.camera.keepAliveTimeout = .greatestFiniteMagnitude
    }

    func applyZoomConfiguration() {

        // Zooming is a camera-session feature and is configured on `model.camera`. Set gestures,
        // discrete zoom steps and the initial zoom factor directly — changes take effect immediately.
        let camera = scannerViewController.model.camera
        camera.isZoomingEnabled = true
        camera.isPinchToZoomEnabled = true
        camera.isDoubleTapToZoomEnabled = true
        // Zoom steps define the discrete stops used by double-tap zooming and constrain the
        // effective zoom range. The first entry is the minimum, the last entry the maximum.
        camera.zoomSteps = [1.0, 12.0]
        camera.initialZoomFactor = 2.0
    }

    func applyEnergyConfiguration() {

        // Energy-saving behavior (detection rates, inactivity timeout) lives on the model's configuration
        // and can be tweaked live.
        let configuration = scannerViewController.model.configuration
        configuration.isEnergySavingEnabled = true
        configuration.inactivityTimeout = 10.0
        configuration.detectionRate = 60
        configuration.energySaveDetectionRate = 5
    }

    func applyViewFinderConfiguration() {

        // The view finder is a set of the model's configuration properties. Toggle it on, change its aspect ratio
        // and appearance — SwiftUI-backed classic UI updates automatically.
        let configuration = scannerViewController.model.configuration
        configuration.isViewFinderEnabled = true
        configuration.viewFinderAspectRatio = SBSDKAspectRatio(width: 8.0, height: 5.0)
        configuration.viewFinderLineColor = UIColor.white.withAlphaComponent(0.85)
    }

}

extension ClassicUIScannerViewController: SBSDKDocumentScannerViewControllerDelegate {
    
    func documentScannerViewController(_ controller: SBSDKDocumentScannerViewController,
                                       didSnapDocumentImage documentImage: SBSDKImageRef,
                                       on originalImage: SBSDKImageRef,
                                       with result: SBSDKDocumentDetectionResult?,
                                       autoSnapped: Bool) {
        // Process the detected document.
        
        // Convert ImageRef to UIImage if needed.
        let documentUIImage = try? documentImage.toUIImage()
    }
    
    func documentScannerViewController(_ controller: SBSDKDocumentScannerViewController,
                                       didFailScanning error: any Error) {
        // Handle the error.
        print("Error scanning document: \(error.localizedDescription)")
    }
}
 
