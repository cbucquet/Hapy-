//
//  ChoseEventViewController.swift
//  HappyV2
//
//  Created by Charles on 10/7/18.
//  Copyright © 2018 charles. All rights reserved.
//

import UIKit

var addedEvent: [String] = []

class ChoseEventViewController: UIViewController {

    @IBAction func titleAction(_ sender: Any) {
        titleTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    @IBAction func messageAction(_ sender: Any) {
        messageTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBAction func cancelButton(_ sender: Any) {
        eventIndexPathToEdit = -1
        dismiss(animated: true)
    }
    @IBAction func addbutton(_ sender: Any) {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMdd"
        addedEvent.append(dateFormatter.string(from: datePicker.date))
        if messageTextField.text?.isEmpty != true{
            addedEvent.append(messageTextField.text!)
        }
        else{
            addedEvent.append("Happy Birthday!")
        }
        
        if SMSemailSegmentControl.selectedSegmentIndex == 0 {
            addedEvent.append("email")
        }
        else{
            addedEvent.append("SMS")
        }
        
        addedEvent.append(titleTextField.text!)
        if eventIndexPathToEdit != -1{
            mainList[indexPathChosen].events[eventIndexPathToEdit] = addedEvent
            eventIndexPathToEdit = -1
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadEvent"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPerson"), object: nil)

        }
        else{
             mainList[indexPathChosen].events.append(addedEvent)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadEvent"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPerson"), object: nil)

        }
        
        
        savePerson()
        
        
        dismiss(animated: true)
        
        
    }
    
    
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var SMSemailSegmentControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addedEvent = []
        popupView.layer.cornerRadius = 10.0
        popupView.layer.masksToBounds = true
        
        cancelButtonOutlet.layer.cornerRadius = 10.0
        cancelButtonOutlet.layer.masksToBounds = true
        addButtonOutlet.layer.cornerRadius = 10.0
        addButtonOutlet.layer.masksToBounds = true
        addButtonOutlet.setTitle("Add", for: .normal)
        
        
        
        if eventIndexPathToEdit != -1{
            
            let eventToEdit = mainList[indexPathChosen].events[eventIndexPathToEdit]
            
            
            titleTextField.text = eventToEdit[3]
            messageTextField.text = eventToEdit[1]
            if eventToEdit[2] == "SMS"{
                SMSemailSegmentControl.selectedSegmentIndex = 1
            }
            else{
                SMSemailSegmentControl.selectedSegmentIndex = 0
            }
            
            let dateFormatterCurrent = DateFormatter()
            dateFormatterCurrent.dateFormat = "MMddyyyy"
            let dateFromString = dateFormatterCurrent.date(from: "\(eventToEdit[0])2019")
            datePicker.date = dateFromString!
            addButtonOutlet.setTitle("Save", for: .normal)
            
        }
        
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTextField.resignFirstResponder()
        messageTextField.resignFirstResponder()
        self.view.endEditing(true)
    }


}
