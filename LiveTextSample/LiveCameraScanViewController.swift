//
//  LiveCameraScanViewController.swift
//  LiveTextSample
//
//  Created by kouichi on 7/3/22.
//

import UIKit
import VisionKit
import AVKit

class LiveCameraScanViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await AVCaptureDevice.requestAccess(for: .video)
        }
    }
    
    @IBAction func showDataScanner(_ sender: Any) {
        if (DataScannerViewController.isAvailable && DataScannerViewController.isSupported) {
            let scannerVC = DataScannerViewController(
                recognizedDataTypes: [.text()],
                qualityLevel: .fast,
                recognizesMultipleItems: false,
                isHighFrameRateTrackingEnabled: false,
                isGuidanceEnabled: true,
                isHighlightingEnabled: true
            )
            scannerVC.delegate = self
            try? scannerVC.startScanning()
            self.present(scannerVC, animated: true)
            
        } else {
            let alertController = UIAlertController(title: "エラー", message: "DataScannerViewControllerが使用できません", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true)
        }
    }
    
}


extension LiveCameraScanViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
        case .text(let text):
            print(text.transcript)
        case .barcode(let barcode):
            print(barcode.payloadStringValue)
        default:
            break
        }
    }
}

