//
//  AddViewController.swift
//  MyFitness
//
//  Created by UMC on 2023/02/01.
//

import UIKit
import CoreData
import Photos
import CoreGraphics
import Combine

protocol AddViewControllerDelegate {
    func refresh()
}

class AddViewController: UIViewController {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var kcalTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var btnStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "AddViewController"

    var delegate: AddViewControllerDelegate?
    var isModify: Bool = false

    var date = Date()
    var distance: String?
    var time: String?
    var kcal: String?
    
    var photoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        dateTextField.text = date.getText(format: "yyyy년 MM월 dd일")
        distanceTextField.text = distance
        timeTextField.text = time
        kcalTextField.text = kcal
        if isModify {
            saveButton.titleLabel?.text = "수정"
        } else {
            saveButton.titleLabel?.text = "저장"
        }
        
        // Get Grant of Health
        getHealthGrant()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func clickRemove(_ sender: Any) {
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date = %@", date as NSDate)
        
        let coreDataManager = CoreDataManager.shared
        let data = coreDataManager.fetch(fetchRequest: fetchRequest)
        let objectToDelete = data[0] as NSManagedObject
        coreDataManager.delete(object: objectToDelete)
        
        delegate?.refresh()
        finish()
    }
    
    @IBAction func clickSave(_ sender: Any) {
        let coreDataManager = CoreDataManager.shared
        
        if isModify {
            let fetchRequest = Entity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date = %@", date as NSDate)
            
            let data = coreDataManager.fetch(fetchRequest: fetchRequest)
            let objectToUpdate = data[0] as NSManagedObject
            objectToUpdate.setValue(distanceTextField.text, forKey: "distance")
            objectToUpdate.setValue(timeTextField.text, forKey: "time")
            objectToUpdate.setValue(kcalTextField.text, forKey: "kcal")
                
            coreDataManager.update(object: objectToUpdate)
        } else {
            let object = coreDataManager.create(entity: Entity.self)
            object.setValue(self.date, forKey: "date")
            object.setValue(distanceTextField.text, forKey: "distance")
            object.setValue(timeTextField.text, forKey: "time")
            object.setValue(kcalTextField.text, forKey: "kcal")
            
            coreDataManager.saveContext()
        }
            
//        guard let entity = NSEntityDescription.entity(forEntityName: "Entity", in: self.container.viewContext) else {
//            return
//        }
//        
//        let data = NSManagedObject(entity: entity, insertInto: self.container.viewContext)
//        data.setValue(self.date, forKey: "date")
//        data.setValue(distanceTextField.text, forKey: "distance")
//        data.setValue(timeTextField.text, forKey: "time")
//        data.setValue(kcalTextField.text, forKey: "kcal")
//        
//        do {
//            try self.container.viewContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
        
        delegate?.refresh()
        finish()
    }
    
    @IBAction func getPhoto(_ sender: UIButton) {
        
        
        
        /*
        Task {
            let isAuthorized = await PermissionManager.shared.checkPhotoLibraryPermission()
            if isAuthorized { openPhotoLibrary() }
        }
         */
    }
         
     //Open PhotoLibrary
     func openPhotoLibrary() {
         let imagePickerController = UIImagePickerController()
         imagePickerController.delegate = self
         imagePickerController.sourceType = .photoLibrary
         imagePickerController.allowsEditing = true
         present(imagePickerController, animated: true, completion: nil)
     }

    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                let height = keyboardSize.height
                btnStackViewBottomConstraint.constant = height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                let height = keyboardSize.height
                btnStackViewBottomConstraint.constant = 0
            }
        }
    }
    
    private func finish() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Add Footwalk
    let healthKitManager = HealthKitManager()
    var cancellableSet = Set<AnyCancellable>()

    func getHealthGrant() {
        Task {
            let grant = await healthKitManager.authorizeHealthKit()
            if grant {
                Toast.shared.showToast("건강권한 획득 완료")
            } else {
                Toast.shared.showToast("건강권한이 없는뎁쇼")
            }
        }
    }
    
    @IBAction func addfootwalks(_ sender: UIButton) {
        Task {
            let result = await healthKitManager.saveStepCount(ofDate: date, steps: 1000)
            if result {
                let textString = "걸음 수 추가했어요..."
                Toast.shared.showToast(textString)
            } else {
                let textString = "걸음 수 추가에 실패했어요..."
                Toast.shared.showToast(textString)
            }
        }
    }
}

extension AddViewController: UINavigationControllerDelegate { }

extension AddViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photoURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            print("photoURL : \(photoURL)")
            self.photoURL = photoURL
        }
        
        picker.dismiss(animated: true, completion: { [weak self] in
            // TODO: - After dismissed

        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func binarize(image: UIImage, threshold: Float) -> UIImage? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        // Convert to grayscale
        let grayScaleFilter = CIFilter(name: "CIPhotoEffectMono")
        grayScaleFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let grayScaleImage = grayScaleFilter?.outputImage else { return nil }
        
        // Binarize
        let binaryFilter = CIFilter(name: "CIColorControls")
        binaryFilter?.setValue(grayScaleImage, forKey: "inputImage")
        binaryFilter?.setValue(1 - threshold, forKey: "inputBrightness")
        binaryFilter?.setValue(0, forKey: "inputSaturation")
        
        guard let outputCIImage = binaryFilter?.outputImage else { return nil }
        
        // Create UIImage from CIImage
        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }

    func convertToGrayScale(image: UIImage) -> UIImage {
        let imageSize = image.size
        let context = CGContext(data: nil, width: Int(imageSize.width), height: Int(imageSize.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: image.cgImage!.bytesPerRow, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)

        context?.draw(image.cgImage!, in: CGRect(origin: .zero, size: imageSize))

        let cgImage = context?.makeImage()

        return UIImage(cgImage: cgImage!)
    }
}
