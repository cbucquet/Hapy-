//
//  TutorialView.swift
//  HappyV2
//
//  Created by Charles on 1/26/19.
//  Copyright © 2019 charles. All rights reserved.
//

import Foundation
import UIKit


class TutorialController: UIViewController, UIScrollViewDelegate{

    
    // Elements from the storyboard
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var StartButtonOutlet: UIButton!
    @IBOutlet weak var SkipButtonOutlet: UIButton!
    
    // Setting an array to the images' names
    var imagesNames: [String] = ["Intro0", "Intro1", "Intro2", "Intro3", "Intro4", "Intro5", "Intro6", "Intro7"]
    
    // Creating a frame that will correspond to each image's frame
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    
    @IBAction func StartButtonAction(_ sender: Any) {
        notFirstTime = true
        UserDefaults.standard.set(notFirstTime, forKey: "notFirstTime")
        performSegue(withIdentifier: "tutorialEnd", sender: nil)
    }
    @IBAction func SkipButtonAction(_ sender: Any) {
        notFirstTime = true
        UserDefaults.standard.set(notFirstTime, forKey: "notFirstTime")
        performSegue(withIdentifier: "tutorialEnd", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the pageControl and the ScrollView
        pageControl.numberOfPages = imagesNames.count
        scroll.frame = view.frame
        
        
        // Adding each image to the ScrollView
        for index in 0...imagesNames.count - 1{
            // Start the image after the next
            //frame.origin.x = scroll.frame.width * CGFloat(index)
            
            frame = CGRect(x: scroll.frame.width * CGFloat(index), y: 0, width: self.scroll.frame.width, height: self.scroll.frame.height)
            
            // Create the ImageView and adding it to the scroll view
            let imageView = UIImageView(frame: frame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: imagesNames[index])
            self.scroll.addSubview(imageView)
            
        }
        
        // Setting the ScrollView's size to fit all of the images
        scroll.contentSize = CGSize(width: scroll.frame.width * CGFloat(imagesNames.count), height: scroll.frame.size.height)
        scroll.delegate = self
        scroll.isPagingEnabled = true
        //scroll.contentSize.width = 0
        
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scroll.addGestureRecognizer(singleTapGestureRecognizer)
        
        //Set up the Start Button
        StartButtonOutlet.setTitle(" Get Started ", for: .normal)
        StartButtonOutlet.layer.cornerRadius = 10
        StartButtonOutlet.layer.borderColor = UIColor.white.cgColor
        StartButtonOutlet.layer.borderWidth = 1
        StartButtonOutlet.tintColor = UIColor.white
        StartButtonOutlet.isHidden = true
        
        //Set up the Skip Button
        SkipButtonOutlet.setTitle(" Skip ", for: .normal)
        SkipButtonOutlet.layer.cornerRadius = 10
        SkipButtonOutlet.layer.borderColor = UIColor.white.cgColor
        SkipButtonOutlet.layer.borderWidth = 1
        SkipButtonOutlet.tintColor = UIColor.white
        SkipButtonOutlet.isHidden = false
        
    }
    @objc func singleTap() {
        if pageControl.currentPage != imagesNames.count - 1 {
            scroll.contentOffset.x += scroll.frame.size.width
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // ********** ScrollView Methods **********
    
    // Change the page number
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var pageNumber = scroll.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        if Int(pageNumber) == imagesNames.count - 1{
            StartButtonOutlet.isHidden = false
            SkipButtonOutlet.isHidden = true
        }
        else{
            StartButtonOutlet.isHidden = true
            SkipButtonOutlet.isHidden = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0{
            scrollView.contentOffset.y = 0
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
