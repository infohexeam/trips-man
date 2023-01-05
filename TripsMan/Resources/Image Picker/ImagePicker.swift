//
//  ImagePicker.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 04/01/23.
//

import Foundation
import UIKit
import Photos

public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?, from sourceView: UIView, imageName: String)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    private var sourceView: UIView!
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        var allowed = false
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            print("authorized")
            if let action = self.action(for: .camera, title: "Take photo") {
                alertController.addAction(action)
            }
            allowed = true
 
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    print("allowed")
                    if let action = self.action(for: .camera, title: "Take photo") {
                        DispatchQueue.main.async {
                            alertController.addAction(action)
                        }
                    }
                    allowed = true
      
                } else {
                    //access denied
                    print("denied")
                }
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            if let action = self.action(for: .photoLibrary, title: "Photo library") {
                alertController.addAction(action)
            }
            allowed = true
        } else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                    if (newStatus == PHAuthorizationStatus.authorized) {
                        if let action = self.action(for: .photoLibrary, title: "Photo library") {
                            DispatchQueue.main.async {
                                alertController.addAction(action)
                            }
                        }
                        allowed = true
                    }
                    else {
                        print("library access denied")
                    }
                })
        }
        
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.sourceView = sourceView
        
        if allowed {
            self.presentationController?.present(alertController, animated: true)
        } else {
            let deniedAlert = UIAlertController(title: nil, message: "TripsMan does not have access to your camera or library. To enable access, tap Settings", preferredStyle: .alert)
            deniedAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            deniedAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }))
            
            self.presentationController?.present(deniedAlert, animated: true)
        }
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?, imageName: String) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image, from: sourceView, imageName: imageName)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil, imageName: "")
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                let asset = result.firstObject
                print(asset?.value(forKey: "filename"))
                return self.pickerController(picker, didSelect: image, imageName: "\(asset?.value(forKey: "filename") ?? "")")
            }
            let imageName = "CAM_" + UUID().uuidString + ".JPG"
            return self.pickerController(picker, didSelect: image, imageName: imageName)
        } else {
            self.pickerController(picker, didSelect: nil, imageName: "")
        }
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
