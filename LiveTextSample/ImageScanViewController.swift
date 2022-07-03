//
//  ImageScanViewController.swift
//  LiveTextSample
//
//  Created by kouichi on 7/3/22.
//

import UIKit
import PhotosUI
import VisionKit

class ImageScanViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }
    }
    
    @IBAction func showImagePicker(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func setImageWithAnalyze(image: UIImage) {
        self.imageView.image = image
        
        interaction.preferredInteractionTypes = []
        interaction.analysis = nil
        guard let image = imageView.image else { return }
        Task {
            let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
            do {
                let analysis = try await analyzer.analyze(image, configuration: configuration)
                if let analysis = analysis {
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .textSelection
                    interaction.selectableItemsHighlighted = true
                }
            }
            catch {
                print(error)
            }
        }
        
    }
}

extension ImageScanViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.setImageWithAnalyze(image: image)
                        }
                    }
                }
            } else {
                //
            }
        }
        // Pickerを閉じる
        picker.dismiss(animated: true)
    }
}
