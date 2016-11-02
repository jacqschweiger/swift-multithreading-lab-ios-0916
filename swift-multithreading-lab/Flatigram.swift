//
//  Flatigram.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 11/2/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit


// MARK: Flatigram class

class Flatigram {
    var image: UIImage?
    var state = ImageState.unfiltered
}

enum ImageState {
    case unfiltered, filtered
}

// MARK: UIImage filtering extension

extension UIImage {
    
    func filter(with filter: String) -> UIImage? {
        
        let coreImage = CIImage(image: self)
        let openGLContext = EAGLContext(api: .openGLES3)
        let context = CIContext(eaglContext: openGLContext!)
        let ciFilter = CIFilter(name: filter)
        ciFilter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        guard let coreImageOutput = ciFilter?.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Could not unwrap output of CIFilter: \(filter)")
            return nil
        }
        
        let output = context.createCGImage(coreImageOutput, from: coreImageOutput.extent)
        let result = UIImage(cgImage: output!)
        
        UIGraphicsBeginImageContextWithOptions(result.size, false, result.scale)
        result.draw(at: CGPoint.zero)
        guard let finalResult = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Could not save final UIImage")
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return finalResult
    }
    
}