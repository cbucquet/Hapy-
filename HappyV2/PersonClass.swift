//
//  PersonClass.swift
//  HappyV2
//
//  Created by Charles on 10/6/18.
//  Copyright © 2018 charles. All rights reserved.
//

import Foundation
import UIKit
let customFont = UIFont(name: "Lollipoon", size: UIFont.systemFontSize)

struct Event {
    var date : Int
    var message : String
    var wayToSend : String
    var emailPhone : String
    var title: String
}
var defaultEvents : [[String]] = [["0101", "Happy New Year!", "SMS", "New Year"], ["0101", "Happy Birthday!", "SMS", "Birthday"], ["0704", "Happy 4th of July!", "SMS", "4th of July"]]


class Person: NSObject, NSCoding {
    
    var name : String
    var events : [[String]]
    var phoneNumber : String
    var email : String
    var picture: UIImage
    
    
    init(name: String, phoneNumber: String, email: String, picture: UIImage) {
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.events = defaultEvents
        self.picture = picture
    }
    init(name: String, phoneNumber: String, email: String, picture: UIImage, events: [[String]]) {
        self.events = events
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        
        self.picture = picture
    }
    init(name: String, phoneNumber: String, email: String, picture: UIImage, events: [[String]], birthday: String) {
        self.events = events
        if birthday != "0000"{
            self.events[1][0] = "\(birthday)"
        }
        
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        
        self.picture = picture
    }
    
    init(name: String, phoneNumber: String, email: String, picture: UIImage, birthday: String) {
        self.events = defaultEvents
        if birthday != "0000"{
            self.events[1][0] = "\(birthday)"
        }
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        
        self.picture = picture
    }
    
    required init (coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        events = aDecoder.decodeObject(forKey: "events") as! [[String]]
        phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        
        let imageData = aDecoder.decodeObject(forKey: "image") as! NSData
        picture = UIImage(data: imageData as Data)!.fixOrientation()

       
        
        //events = aDecoder.decodeObject(forKey: "events") as! [Event]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(events, forKey: "events")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(phoneNumber, forKey: "phoneNumber")
        
        if let imageData: NSData = picture.pngData() as NSData?{
            aCoder.encode(imageData, forKey: "image")
        }

        
        
        
        //aCoder.encode(self.events, forKey: "events")
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
    let textColor = UIColor.white
    let textFont = customFont
    let newFont = textFont?.withSize(250)
    
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
    
    let textFontAttributes = [
        NSAttributedString.Key.font: newFont!,
        NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
    
    let rect = CGRect(origin: point, size: image.size)
    text.draw(in: rect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
