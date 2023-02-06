//
//  AddViewController.swift
//  MyFitnes
//
//  Created by UMC on 2023/02/01.
//

import UIKit
import CoreData

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
    
    static let identifier = "AddViewController"
    private var container: NSPersistentContainer!
    
    var delegate: AddViewControllerDelegate?
    var isModify: Bool = false

    var date = Date()
    var distance: String?
    var time: String?
    var kcal: String?    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
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
}
