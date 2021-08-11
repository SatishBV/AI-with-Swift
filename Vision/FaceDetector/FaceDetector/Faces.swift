//
//  Faces.swift
//  FaceDetector
//
//  Created by Satish Bandaru on 11/08/21.
//

import UIKit
import Vision

extension UIImage {
    func detectFaces(_ completion: @escaping ([VNFaceObservation]?) -> Void) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceRectanglesRequest()
        
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(cgImage: image,
                                                orientation: self.cgImageOrientation)
            
            try? handler.perform([request])
            
            guard let observations = request.results as? [VNFaceObservation] else {
                return completion(nil)
            }
            
            completion(observations)
        }
    }
}

extension Collection where Element == VNFaceObservation {
    func drawOn(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size,
                                               false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.01 * image.size.width)
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        
        for observation in self {
            let rect = observation.boundingBox
            
            let normalizedRect = VNImageRectForNormalizedRect(rect,
                                                              Int(image.size.width),
                                                              Int(image.size.height)).applying(transform)
            context.stroke(normalizedRect)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
