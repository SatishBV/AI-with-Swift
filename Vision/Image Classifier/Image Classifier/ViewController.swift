//
//  ViewController.swift
//  Image Classifier
//
//  Created by Satish Bandaru on 15/08/21.
//

import UIKit
import MobileCoreServices
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var classifyButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    private var inputImage: UIImage?
    var classification: String?
    private let classifier = VisionClassifier(mlmodel: FruitClassifier().model)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.placeholder
        
        classifier?.delegate = self
        refresh()
    }

    @IBAction func selectButtonPressed(_ sender: Any) {
        getPhoto()
    }
    
    @IBAction func classifyButtonPressed(_ sender: Any) {
        classifyImage()
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        getPhoto(camera: true)
    }
    
    func refresh() {
        if inputImage == nil {
            classLabel.text = "Pick or take a photo"
            imageView.image = UIImage.placeholder
            classifyButton.isEnabled = false
            classifyButton.backgroundColor = .lightGray
        } else {
            imageView.image = inputImage
            
            if classification == nil {
                classLabel.text = "None"
                classifyButton.isEnabled = true
                classifyButton.backgroundColor = .systemBlue
            } else {
                classLabel.text = classification
                classifyButton.isEnabled = false
                classifyButton.backgroundColor = .lightGray
            }
        }
    }
    
    func classifyImage() {
        if let classifier = self.classifier, let image = inputImage {
            classifier.classify(image)
            classifyButton.isEnabled = false
            classifyButton.backgroundColor = .lightGray
        }
    }
}

extension UIImage {
    static let placeholder: UIImage? = UIImage(named: "placeholder")
}

extension ViewController: UINavigationControllerDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate {
    func getPhoto(camera: Bool = false) {
        let photoSource: UIImagePickerController.SourceType
        photoSource = camera ? .camera : .photoLibrary

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = photoSource
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        inputImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        classification = nil

        picker.dismiss(animated: true)
        refresh()

        if inputImage == nil {
            summonAlertView(message: "Image was malformed.")
        }
    }

    func summonAlertView(message: String? = nil) {
        let alertController = UIAlertController(title: "Error",
                                                message: message ?? "Action could not be completed",
                                                preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        present(alertController, animated: true)
    }
}
