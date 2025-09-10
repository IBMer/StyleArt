//
//  ViewController.swift
//  StyleArts
//
//  Created by Levin on 14/6/2017.
//  Copyright © 2017 Levin . All rights reserved.
//

import UIKit
import CoreML
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //MARK:- IBOutlets
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK:- Properties
    var originalImage:UIImage?
    var processedImage:UIImage?
  
    //MARK:- ViewController life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imageView.layer.cornerRadius = 4
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
       self.originalImage = self.imageView.image
       CollectionView.delegate = self
       CollectionView.dataSource = self
        
    }
    //MARK:- Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- IBActions
    @IBAction func camera(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func saveToPhotos(_ sender: Any) {
        guard let imageToSave = processedImage ?? imageView.image else {
            showAlert(title: "No Image", message: "No image to save. Please select and process an image first.")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.saveImageToPhotos(imageToSave)
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showAlert(title: "Permission Denied", message: "Please allow access to Photos in Settings to save images.")
                }
            case .notDetermined:
                DispatchQueue.main.async {
                    self.showAlert(title: "Permission Required", message: "Please grant permission to access Photos.")
                }
            case .limited:
                DispatchQueue.main.async {
                    self.saveImageToPhotos(imageToSave)
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Unknown permission status.")
                }
            }
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    let size = image.size
                    self.showAlert(title: "Saved Successfully", 
                                 message: "Image saved to Photos!\nSize: \(Int(size.width)) × \(Int(size.height)) pixels")
                } else {
                    self.showAlert(title: "Save Failed", 
                                 message: error?.localizedDescription ?? "Failed to save image")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    //MARK:- CollectionView datasource and delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell:FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filter", for: indexPath) as! FilterCollectionViewCell
        switch indexPath.item {
        case 0:
            cell.lbl.text = "Mosaic"
            cell.imageView.image = #imageLiteral(resourceName: "mosaicImg")
        case 1:
            cell.lbl.text = "Scream"
            cell.imageView.image = #imageLiteral(resourceName: "screamImg")
        case 2:
            cell.lbl.text = "Muse"
            cell.imageView.image = #imageLiteral(resourceName: "museImg")
        case 3:
            cell.lbl.text = "Udnie"
            cell.imageView.image = #imageLiteral(resourceName: "Udanie")
        case 4:
            cell.lbl.text = "Candy"
            cell.imageView.image = #imageLiteral(resourceName: "candy")
        case 5:
            cell.lbl.text = "Feathers"
            cell.imageView.image = #imageLiteral(resourceName: "Feathers")
       
        default:
            cell.lbl.text = ""
        }
        
        
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        DispatchQueue.main.async {
            self.view.showHud(message: "Loading")
        }
        
        if self.imageView.image != nil{
            
            StyleArt.shared.process(image: self.originalImage!, style: ArtStyle(rawValue: indexPath.row)!, compeletion: { (result) in
                
                if let image = result{
                    self.processedImage = image
                    self.imageView.image = image
                }
            })
        }
        
        DispatchQueue.main.async {
            self.view.hideHud()
        }

}
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true)
      
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
          originalImage = image
          imageView.image = image
    }
    
    
    
}
