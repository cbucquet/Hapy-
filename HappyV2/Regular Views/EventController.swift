//
//  EventController.swift
//  HappyV2
//
//  Created by Charles on 10/6/18.
//  Copyright © 2018 charles. All rights reserved.
//

import Foundation
import UIKit


import MessageUI

var eventIndexPathToEdit = -1
class EventController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadEvent"), object: nil) 
        navigationBar.title = "Events"
        navigationBar.backBarButtonItem?.tintColor = UIColor.init(red: 153/255, green: 1, blue: 51, alpha: 1)
        navigationBar.backBarButtonItem?.title = "back"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.reloadData()
        }
    }
    @objc func loadList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
            
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mainList[indexPathChosen].events[indexPath.row][2] == "SMS"{
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = mainList[indexPathChosen].events[indexPath.row][1]
                controller.recipients = [mainList[indexPathChosen].phoneNumber]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
            else{
                self.notif(titleGiven: "Error", messageGiven: "It looks like SMS cannot be sent. Please try again later")
            }
        }
        else{
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setSubject(mainList[indexPathChosen].events[indexPath.row][3])
                mail.setToRecipients([mainList[indexPathChosen].email])
                mail.setMessageBody(mainList[indexPathChosen].events[indexPath.row][1], isHTML: false)
                present(mail, animated: true, completion: nil)
            }
            else {
                self.notif(titleGiven: "Error", messageGiven: "It looks like emails cannot be sent. Please try again later")
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainList[indexPathChosen].events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")
        cell?.backgroundColor = UIColor.clear
        
        if  mainList[indexPathChosen].events.count > 0 && mainList[indexPathChosen].events[indexPath.row].count == 4{
            (cell?.viewWithTag(10)!.viewWithTag(1) as! UILabel).text = mainList[indexPathChosen].events[indexPath.row][3]
            
            var dateForEvent = mainList[indexPathChosen].events[indexPath.row][0]
            dateForEvent.insert("/", at: dateForEvent.index(dateForEvent.startIndex, offsetBy: 2))
            (cell?.viewWithTag(10)!.viewWithTag(2) as! UILabel).text = dateForEvent
            
            (cell?.viewWithTag(10)!.viewWithTag(3) as! UILabel).text = mainList[indexPathChosen].events[indexPath.row][2]
            (cell?.viewWithTag(10)!.viewWithTag(4) as! UILabel).text = mainList[indexPathChosen].events[indexPath.row][1]

        }
        else{
            (cell?.viewWithTag(10)!.viewWithTag(1) as! UILabel).text = ""
            (cell?.viewWithTag(10)!.viewWithTag(2) as! UILabel).text = ""
            (cell?.viewWithTag(10)!.viewWithTag(3) as! UILabel).text = ""
            (cell?.viewWithTag(10)!.viewWithTag(4) as! UILabel).text = ""

        }
        
        cell?.viewWithTag(10)!.layer.cornerRadius = 20
        let shadowPath2 = UIBezierPath(roundedRect: (cell?.viewWithTag(10)!.bounds)!, cornerRadius: 20)
        
        cell?.viewWithTag(10)!.layer.masksToBounds = false
        cell?.viewWithTag(10)!.layer.shadowColor = UIColor.black.cgColor
        cell?.viewWithTag(10)!.layer.shadowOffset = CGSize(width: CGFloat(1.2), height: CGFloat(1.2))
        cell?.viewWithTag(10)!.layer.shadowOpacity = 0.4
        cell?.viewWithTag(10)!.layer.shadowPath = shadowPath2.cgPath
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            // TODO: Delete todo
            mainList[indexPathChosen].events.remove(at: indexPath.row)
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
            eventIndexPathToEdit = indexPath.row
            self.performSegue(withIdentifier: "changeEvent", sender: self)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.title = nil
        action.backgroundColor = colorTheme
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    func notif(titleGiven: String, messageGiven: String){
        let alert = UIAlertController(title: titleGiven, message: messageGiven, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
