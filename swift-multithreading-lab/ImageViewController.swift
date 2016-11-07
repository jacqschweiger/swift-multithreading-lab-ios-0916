//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


//MARK: Image View Controller

class ImageViewController : UIViewController {
    
    var scrollView: UIScrollView!
    var imageView = UIImageView()
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let filtersToApply = ["CIBloom",
                          "CIPhotoEffectProcess",
                          "CIExposureAdjust"]
    var flatigram = Flatigram()

    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpViews()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func filterButtonTapped(_ sender: AnyObject) {
        switch flatigram.state {
        case .unfiltered:
            startProcess()
        case .filtered:
            presentFilteredAlert()
        }
    
    }
    
    func startProcess() {
        
        filterButton.isEnabled = false
        chooseImageButton.isEnabled = false
        activityIndicator.startAnimating()
        
        filterImage { result in
            
            OperationQueue.main.addOperation {
                result ? print("Image successfully filtered") : print("Image filtering did not complete")
                self.imageView.image = self.flatigram.image
                self.activityIndicator.stopAnimating()
                self.filterButton.isEnabled = true
                self.chooseImageButton.isEnabled = true
            }
        
//        filterImage { (true) in
//            print("button tapped")
//            for filter in self.filtersToApply {
//                self.imageView.image = self.flatigram.image?.filter(with: filter)
//            }
        }
        
        
        
    }
    
}

extension ImageViewController {
    
    func filterImage(with completion: @escaping (Bool) -> () ) {
        var queue = OperationQueue()
        queue.name = "Image Filtration Queue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        var remainingOperations = filtersToApply.count {
            didSet {
                if remainingOperations == 0 {
                    print("All operations finished")
                    self.flatigram.state = .filtered
                    completion(true)
                } else {
                    print("Waiting on \(queue.operationCount) operations to complete")
                }
                
            }
        }
        
        for filter in filtersToApply {
            
            let filterer = FilterOperation(flatigram: flatigram, filter: filter)
            filterer.completionBlock = {
                
                if filterer.isCancelled {
                    completion(false)
                    return
                }
                
                remainingOperations -= 1
            }
            
            queue.addOperation(filterer)
            print("Added FilterOperation with \(filter) to \(queue.name)")
        }
        

    }
    
    
}





