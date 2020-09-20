//
//  ChosePersonViewController.swift
//  HappyV2
//
//  Created by Charles on 10/7/18.
//  Copyright © 2018 charles. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import Photos

var colorTheme = UIColor(red: 131/255, green: 214/255, blue: 47/255, alpha: 1)

class ChosePersonViewController: UIViewController, CNContactPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var birthDay = "0000"
    @IBAction func nameAction(_ sender: Any) {
        nameTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    @IBAction func phoneAction(_ sender: Any) {
        phoneNumberTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBAction func emailAction(_ sender: Any) {
        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    
    @IBOutlet weak var defaultEventsLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var defaultEventSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.image = #imageLiteral(resourceName: "profile pic")
        popupView.layer.cornerRadius = 10.0
        popupView.layer.masksToBounds = true
        
        cancelButtonOutlet.layer.cornerRadius = 10.0
        cancelButtonOutlet.layer.masksToBounds = true
        addButtonOutlet.layer.cornerRadius = 10.0
        addButtonOutlet.layer.masksToBounds = true
        addButtonOutlet.setTitle("Add", for: .normal)
        
        contactsOutlet.layer.borderWidth = 1
        contactsOutlet.layer.borderColor = colorTheme.cgColor
        contactsOutlet.layer.cornerRadius = 10.0
        contactsOutlet.layer.masksToBounds = true
        
        
        profilePicture.layer.borderWidth = 0
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        profilePicture.layer.cornerRadius = 40
        profilePicture.layer.masksToBounds = true
        
        
        selectPictureoutlet.layer.borderWidth = 1
        selectPictureoutlet.layer.borderColor = colorTheme.cgColor
        selectPictureoutlet.layer.cornerRadius = 10.0
        selectPictureoutlet.layer.masksToBounds = true
        
        defaultEventsLabel.isHidden = false
        defaultEventSwitch.isHidden = false
        
        if personIndexPathToEdit != -1{
            let personToEdit = mainList[personIndexPathToEdit]
            
            profilePicture.image = personToEdit.picture
            nameTextField.text = personToEdit.name
            emailTextField.text = personToEdit.email
            phoneNumberTextField.text = personToEdit.phoneNumber
            defaultEventsLabel.isHidden = true
            defaultEventSwitch.isHidden = true
            addButtonOutlet.setTitle("Edit", for: .normal)
        
        }
        
        
        birthDay = "0000"
    }
    
    @IBOutlet weak var selectPictureoutlet: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBAction func selectPictureAction(_ sender: Any) {
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.chooseImage()
                }
                else {
                     self.notif(titleGiven: "Permisson Denied", messageGiven: "Please go to Settings and allow Hapy! to access your images")
                }
            })
        }
            
        else if photos == .authorized{
            chooseImage()
        }
        else{
            self.notif(titleGiven: "Permisson Denied", messageGiven: "Please go to Settings and allow Hapy! to access your images")
        }
        
    }
    
    func chooseImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        profilePicture.layer.borderWidth = 0
        
        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            profilePicture.image = image
            profilePicture.layer.borderWidth = 1
            
        }
        else{
            //ERROR
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: Any) {
        personIndexPathToEdit = -1
        dismiss(animated: true)
    }
    @IBOutlet weak var contactsOutlet: UIButton!
    @IBAction func contactsAction(_ sender: Any) {
        
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error{
                 self.notif(titleGiven: "Error", messageGiven: "\(err). Please try again later")
            }
            if granted{
                
                self.chooseContacts()
            }
            else{
                self.notif(titleGiven: "Permisson Denied", messageGiven: "Please go to Settings and allow Hapy! to access your contacts")
            }
        }
        
        
        /*let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
         let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
         do{
         try store.enumerateContacts(with: request, usingBlock: { (contact, <#UnsafeMutablePointer<ObjCBool>#>) in
         <#code#>
         })
         }*/
        
        
    }
    
    func chooseContacts(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactNicknameKey ,CNContactEmailAddressesKey]
        
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact){
        profilePicture.layer.borderWidth = 0
        
        if let emailValue : CNLabeledValue = contact.emailAddresses.first{
            emailTextField.text = emailValue.value as String
        }
        if let phoneNumberValue : CNLabeledValue = contact.phoneNumbers.first{
            phoneNumberTextField.text = phoneNumberValue.value.stringValue
        }
        nameTextField.text = contact.givenName + " " + contact.familyName
        
        if contact.imageDataAvailable == true{
            profilePicture.layer.borderWidth = 1
            profilePicture.image = UIImage(data: contact.imageData!)!
        }
        else{
            profilePicture.image = #imageLiteral(resourceName: "profile pic")
        }
        if let dateComponents = contact.birthday{
            var dayDate = "\(dateComponents.day!)"
            var monthDate = "\(dateComponents.month!)"
            if (dateComponents.month)! < 10{
                monthDate = "0\(dateComponents.month!)"
                
            }
            if (dateComponents.day)! < 10{
                dayDate = "0\(dateComponents.day!)"
            }
            birthDay = "\(monthDate)\(dayDate)"
        }
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        if !(nameTextField.text?.isEmpty)! && (!(phoneNumberTextField.text?.isEmpty)! || !(emailTextField.text?.isEmpty)!) {
            
            var personAdd = Person(name: ".", phoneNumber: ".", email: ".", picture: UIImage())
            if personIndexPathToEdit != -1{
                
                personAdd = Person(name: nameTextField.text!, phoneNumber: phoneNumberTextField.text!, email: emailTextField.text!, picture: profilePicture.image ?? UIImage(), events: mainList[personIndexPathToEdit].events, birthday: birthDay)
                
                mainList[personIndexPathToEdit] = personAdd
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPerson"), object: nil)
                personIndexPathToEdit = -1
            }
                
            else{
                if defaultEventSwitch.isOn == true{
                    personAdd = Person(name: nameTextField.text!, phoneNumber: phoneNumberTextField.text!, email: emailTextField.text!, picture: profilePicture.image ?? UIImage(), birthday: birthDay)
                }
                else{
                    personAdd = Person(name: nameTextField.text!, phoneNumber: phoneNumberTextField.text!, email: emailTextField.text!, picture: profilePicture.image ?? UIImage(), events: [[]], birthday: birthDay)
                }
                
                mainList.append(personAdd)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPerson"), object: nil)
            }
            
            
            
            savePerson()
            dismiss(animated: true)
        }
        else{
            //ERROR FILL TEXT FIELDS
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func notif(titleGiven: String, messageGiven: String){
        let alert = UIAlertController(title: titleGiven, message: messageGiven, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
