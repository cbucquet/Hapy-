//  ViewController.swift
//  HappyV2
//
//  Created by Charles on 10/6/18.
//  Copyright © 2018 charles. All rights reserved.
//

import UIKit
import MessageUI
import UserNotifications
import Contacts
import ContactsUI


var personIndexPathToEdit = -1
var indexPathChosen = 0
var mainList : [Person] = [Person(name: "Default", phoneNumber: "1234567890", email: "charles.charles", picture: #imageLiteral(resourceName: "profile pic"), events: [["0328","Happy Birthday!", "SMS", "Birthday"]])]

var notFirstTime = true



class ViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UNUserNotificationCenterDelegate, CNContactPickerDelegate{
    
    
    @IBAction func sendMessagesButton(_ sender: Any) {
        checkIfDay()
    }
    @IBOutlet weak var titleBar: UINavigationItem!
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        //headerView.layer.borderWidth = 1
        //headerView.layer.borderColor = UIColor.black.cgColor
        //headerView.layer.cornerRadius = 10
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeScreenCell")
        cell?.backgroundColor = UIColor.clear
        
        (cell?.viewWithTag(10)!.viewWithTag(2) as! UILabel).text = mainList[indexPath.row].name
        

        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).image = mainList[indexPath.row].picture
        
        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).layer.borderColor = UIColor.lightGray.cgColor
        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).layer.borderWidth = 1
        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).layer.cornerRadius = (cell?.viewWithTag(1) as! UIImageView).frame.size.height / 2
        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).layer.masksToBounds = true
        (cell?.viewWithTag(10)!.viewWithTag(1) as! UIImageView).image = (cell?.viewWithTag(1) as! UIImageView).image?.fixOrientation()
        
        if  mainList[indexPath.row].events.count > 0{
            if mainList[indexPath.row].events[0].count == 4{
                let valuesToDisplay = closestEvent(events: mainList[indexPath.row].events)
                var dateToDisplay = valuesToDisplay.1
                dateToDisplay.insert("/", at: dateToDisplay.index(dateToDisplay.startIndex, offsetBy: 2))
                (cell?.viewWithTag(10)!.viewWithTag(3) as! UILabel).text = valuesToDisplay.0
                (cell?.viewWithTag(10)!.viewWithTag(4) as! UILabel).text = dateToDisplay
            }
        }
        
        cell?.viewWithTag(10)!.layer.cornerRadius = 20
        let shadowPath2 = UIBezierPath(roundedRect: (cell?.viewWithTag(10)!.bounds)!, cornerRadius: 20)
        
        cell?.viewWithTag(10)!.layer.masksToBounds = false
        cell?.viewWithTag(10)!.layer.shadowColor = UIColor.black.cgColor
        cell?.viewWithTag(10)!.layer.shadowOffset = CGSize(width: CGFloat(1.2), height: CGFloat(1.2))
        cell?.viewWithTag(10)!.layer.shadowOpacity = 0.4
        cell?.viewWithTag(10)!.layer.shadowPath = shadowPath2.cgPath
        //cell?.viewWithTag(10)!.layer.shadowRadius = 2
        
        
        
        return cell!
    }
    
    
    func closestEvent(events: [[String]]) -> (String,String){
        var name = ""
        var closestDate = "1000000"
        var currentDate = getDate()
        var stillNegative = true
        
        for event in events{
            var dateToCompare = Int(event[0])!
            if stillNegative == true && dateToCompare-Int(currentDate)! >= 0{
                closestDate = event[0]
                name = event[3]
                stillNegative = false
            }
                
            else if dateToCompare-Int(currentDate)! < Int(closestDate)!-Int(currentDate)! {
                closestDate = event[0]
                name = event[3]
            }
        }
        
        
        return (name,closestDate)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathChosen = indexPath.row
        performSegue(withIdentifier: "event", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            // TODO: Delete todo
            mainList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            savePerson()
            completion(true)
        }


        action.image = UIImage(named: "trash")
        action.title = nil

        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Change info") { (action, view, completion) in
            personIndexPathToEdit = indexPath.row
            self.performSegue(withIdentifier: "changePerson", sender: self)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.title = nil
        action.backgroundColor = colorTheme
        
        return UISwipeActionsConfiguration(actions: [action])
    }

    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = colorTheme
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        { (granted, error) in
            // Enable or disable features based on authorization
        }
        
        let current = UNUserNotificationCenter.current()
        current.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        

        
        // Do any additional setup after loading the view, typically from a nib.
        if let savedList = UserDefaults.standard.object(forKey: "person") as? Data {
            mainList = (NSKeyedUnarchiver.unarchiveObject(with: savedList) as? [Person])!
        }
        //mainList.append(Person(name: "Carlito de la Muerte", phoneNumber: "+19143200485", email: "charles@bucquet.com", picture: UIImage(named: "lol.png")!, events: [["0328", "HB Bro!", "SMS", "Birthday"]]))
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadPerson"), object: nil)

        SetReminders()
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (notifications) in
            //print("num of pending notifications \(notifications.count)")
            
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.reloadData()
        }
        
        notFirstTime = UserDefaults.standard.bool(forKey: "notFirstTime")
        if !notFirstTime{
            tutorial()
        }
        
    }
    
    func tutorial(){
       performSegue(withIdentifier: "tutorialStart", sender: self)
    }
    @IBAction func Help(_ sender: Any) {
        tutorial()
    }
    
    @objc func loadList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }

        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // To show the banner in-app
        completionHandler([.badge, .alert, .sound])
    }
    
    var eventsToSend = [[String]]()
    var peopleToSend = [Person]()
    
    func checkIfDay(){
        
        let currentDate = getDate()
        
        for person in mainList{
            for event in person.events{
                if event.count > 0{
                    if event[0] == currentDate{
                        peopleToSend.append(person)
                        eventsToSend.append(event)
                    }
                }
            }
        }
        
        if eventsToSend.count == peopleToSend.count && peopleToSend.count != 0{
            presentMessages()
        }
        else{
            let alertView = UIAlertController(title: "No Message Today", message: "It looks like nobody is celebrating their day today.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertView, animated: true, completion: nil)
        }
        
    }
    func presentMessages(){
        
        for index in 0...peopleToSend.count-1{
            if eventsToSend[index][2] == "SMS"{
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = eventsToSend[index][1]
                    controller.recipients = [peopleToSend[index].phoneNumber]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: {
                        self.peopleToSend.remove(at: 0)
                        self.eventsToSend.remove(at: 0)
                    })
                }
                else{
                   
                    self.notif(titleGiven: "Error", messageGiven: "It looks like SMS cannot be sent. Please try again later")
                }
            }
            else{
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setSubject(eventsToSend[index][3])
                    mail.setToRecipients([peopleToSend[index].email])
                    mail.setMessageBody(eventsToSend[index][1], isHTML: false)
                    present(mail, animated: true, completion: {
                        self.peopleToSend.remove(at: 0)
                        self.eventsToSend.remove(at: 0)
                    })
                }
                else {
                    self.notif(titleGiven: "Error", messageGiven: "It looks like emails cannot be sent. Please try again later")
                    
                }
            }
        }
    }
    
    func getDate() -> String{
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        var dayString = "\(day)"
        let month = calendar.component(.month, from: date)
        var monthString = "\(month)"
        
        if day < 10{
            dayString = "0\(day)"
        }
        
        if month < 10 {
            monthString = "0\(month)"
        }
        
        let todayDate = "\(monthString)\(dayString)"
        
        return todayDate
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            if self.eventsToSend.count == self.peopleToSend.count && self.peopleToSend.count != 0{
                self.presentMessages()
            }
        })
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: {
            if self.eventsToSend.count == self.peopleToSend.count && self.peopleToSend.count != 0{
                self.presentMessages()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func notif(titleGiven: String, messageGiven: String){
        let alert = UIAlertController(title: titleGiven, message: messageGiven, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

}

func savePerson(){
    let SavedData = NSKeyedArchiver.archivedData(withRootObject: mainList)
    
    let defaults = UserDefaults.standard
    defaults.set(SavedData, forKey: "person")
    
}

func SetReminders(){
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    for person in mainList{
        for event in person.events{
            let content = UNMutableNotificationContent()
            content.title = "It is \(person.name)'s day"
            content.subtitle = "Make sure to celebrate his/her \(event[3])!"
            content.body = "Click here to send your prewritten message"
            //content.badge = (Int(truncating: content.badge ?? 0) + 1) as NSNumber
            content.badge = 1
            content.sound = .default
            
            
            
            var date = DateComponents()
            
            var dateForEvent = event[0]
            dateForEvent.insert("/", at: dateForEvent.index(dateForEvent.startIndex, offsetBy: 2))
            let dateForEventArray: [String] = dateForEvent.components(separatedBy: "/")
            
            date.day = Int(dateForEventArray[1])!
            date.month = Int(dateForEventArray[0])!
            date.hour = 0
            date.minute = 0
            date.second = 0
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "\(person).\(event[3])", content: content, trigger: trigger)
            
            
            UNUserNotificationCenter.current().add(request)
            
        }
    }
    
    
}


extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}



