//
//  ViewController.swift
//  SmartCamera
//
//  Created by Caleb Rudnicki on 7/18/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import CDAlertView

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    let apiKey = "ee87dc4e376c0e1b541f4017b23fc903c7abb7ab"
    let version = "2017-7-18"
    var classificationResults : [String] = []
    var objectToFind: String? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let coreDataHelper = CoreDataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        appDelegate.userObjects = coreDataHelper.retrieveObjectFromCoreData(context: appDelegate.persistentContainer.viewContext)
        generateNewObject()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function generates a new object and displays it
    func generateNewObject() {
        let randomIndex = Int(arc4random_uniform(UInt32(appDelegate.userObjects.count)))
        objectToFind = appDelegate.userObjects[randomIndex]
        self.navigationItem.title = "Find a " + appDelegate.userObjects[randomIndex]
    }
    
    //This function is a delegate function that runs when the image appears on the screen as it calls Watson to recognize the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                self.classificationResults = []
                for i in 0..<classes.count {
                    self.classificationResults.append(classes[i].classification)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
            
                if self.classificationResults.contains(self.objectToFind!.lowercased()) {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showAlarmViewControllerSegue", sender: nil)
                        self.appDelegate.stopSound()
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = CDAlertView(title: "You did not find the right item", message: "You can dismiss this message and try again or you can generate a new item.", type: .error)
                        let newObjectAction = CDAlertViewAction(title: "New Object", font: UIFont (name: "HelveticaNeue-UltraLight", size: 16), textColor: UIColor.blue, backgroundColor: UIColor.white, handler: {(CDAlertAction) -> Void in
                            self.generateNewObject()
                            self.imageView.image = nil
                        })
                        let dismissAction = CDAlertViewAction(title: "Try Again", font: UIFont (name: "HelveticaNeue-UltraLight", size: 16), textColor: UIColor.blue, backgroundColor: UIColor.white, handler: {(CDAlertAction) -> Void in
                            self.cameraButtonTapped(self.cameraButton)
                        })
                        alert.add(action: newObjectAction)
                        alert.add(action: dismissAction)
                        alert.hideAnimations = { (center, transform, alpha) in
                            transform = CGAffineTransform(scaleX: 3, y: 3)
                            alpha = 0
                        }
                        alert.hideAnimationDuration = 0.85
                        alert.hasShadow = true
                        alert.show()
                    }
                }
                
            })
        } else {
            print("There was an error when picking the image")
        }
    }

    //This function opens the camera when the camera button is tapped
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    

}

