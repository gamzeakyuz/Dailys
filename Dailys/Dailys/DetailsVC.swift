//
//  DetailsVC.swift
//  Dailys
//
//  Created by GAMZE AKYÜZ on 9.06.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var save: UIButton!
    
    var chosenDailys = ""
    var chosenDailyId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenDailys != ""{
            
            save.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Dailys")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenDailyId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let result = try context.fetch(fetchRequest)

                if result.count > 0 {
                    for result in result as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            titleField.text = title
                        }
                        if let contents = result.value(forKey: "content") as? String{
                            contentField.text = contents
                        }
                        if let date = result.value(forKey: "date") as? String{
                            dateField.text = date
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let imageview = UIImage(data: imageData)
                            image.image = imageview
                        }
                    }
                }
                
            } catch  {
                print("Error")
            }
        }else{
            save.isHidden = false
            save.isEnabled = false
            titleField.text = ""
            contentField.text = ""
            dateField.text = ""
        }
            

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        image.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTapRecognizer)
        
    }
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        save.isEnabled = true
        self.dismiss(animated: true,completion: nil)
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newDailys = NSEntityDescription.insertNewObject(forEntityName: "Dailys", into: context)
        
        newDailys.setValue(titleField.text!, forKey: "title")
        newDailys.setValue(contentField.text!, forKey: "content")
        newDailys.setValue(dateField.text, forKey: "date")
        newDailys.setValue(UUID(), forKey:"id")
        let data = image.image?.jpegData(compressionQuality: 0.5)
        newDailys.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Success")
        } catch  {
            print("there is an error somewhere check it")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }

    
    
}
