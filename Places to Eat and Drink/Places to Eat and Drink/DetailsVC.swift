//
//  DetailsVC.swift
//  Places to Eat and Drink
//
//  Created by Hunt, Rachel on 28/11/2024.
//

import UIKit
import Foundation

class DetailsVC: UIViewController {
    //MARK: Variable Initialisation
    let userDefaults = UserDefaults.standard
    
    var prevVC: String = ""//tells code previous view to know which unwind button to have active
    //back buttons
    @IBOutlet weak var toMapBtn: UIBarButtonItem!
    @IBOutlet weak var toTableBtn: UIBarButtonItem!
    
    //title
    @IBOutlet weak var navItem: UINavigationItem!
    var titleString: String = ""
    
    //building
    var buildingString: String = ""
    
    @IBOutlet weak var descTextView: UITextView!
    var descriptionString: String = ""
    
    //url
    @IBOutlet weak var urlTextView: UITextView!
    var urlString: String?
    
    //opening times
    @IBOutlet var openingTimesLabels: [UILabel]!
    var openingTimesArr: [String]?
    
    @IBOutlet weak var amenitiesTextView: UITextView!
    var amenitiesArr: [String]?
    var amenitiesString: String = ""
    
    //opinion buttons
    @IBOutlet var opinionBtns: [UIButton]!
    var btnSelected: [Bool]? = [false, true, false] //initial values for if button is selected upon startup, for testing
    
    //opinion Button Functions
    @IBAction func dislikeBtn(_ sender: UIButton) {
        //resets opinion for user defailts whenever button clicked - same for all three buttons
        userDefaults.removeObject(forKey: titleString)
        btnSelected = [true, false, false]
        userDefaults.set(btnSelected, forKey: titleString)
        
        setBtnImages(array: btnSelected!)
    }
    
    @IBAction func neutralBtn(_ sender: UIButton) {
        userDefaults.removeObject(forKey: titleString)
        btnSelected = [false, true, false]
        userDefaults.set(btnSelected, forKey: titleString)
        
        setBtnImages(array: btnSelected!)
    }
    
    @IBAction func likeBtn(_ sender: UIButton) {
        userDefaults.removeObject(forKey: titleString)
        btnSelected = [false, false, true]
        userDefaults.set(btnSelected, forKey: titleString)
        
        setBtnImages(array: btnSelected!)
    }
    //last modified
    @IBOutlet weak var lastModifiedLabel: UILabel!
    var lastModifiedString: String?

    //MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setting opinion buttons based on previous user input (if any)
        if userDefaults.object(forKey: titleString) != nil {
            btnSelected = userDefaults.object(forKey: titleString) as? [Bool]
            print("found button selected from previous use")
        }
        
        else {
            //sets default for user opinion if nothing saved in user defaults.
            btnSelected = [false, true, false]
        }
        
        setBtnImages(array: btnSelected!)
        
        //setting correct back button based on previous view
        if prevVC == "MapVC" {
            print("previous view: Map Scene")
            navItem.leftBarButtonItem = toMapBtn
            toTableBtn.isHidden = true
        }
        
        else if prevVC == "PlacesTableVC" {
            print("previous view: Table Scene")
            navItem.leftBarButtonItem = toTableBtn
            toMapBtn.isHidden = true
        }
        
        else {
            print("could not find previous view.")
        }
    }
    
    //MARK: Aesthetic Functions
    //setting text for details
    func setText() {
        navItem.title = titleString
        navItem.prompt = buildingString
        
        if descriptionString == "" {
            descTextView.text = "No description available for this venue."
            descTextView.textAlignment = .center
        }
        
        else {
            descTextView.text = descriptionString
        }
        
        urlTextView.text = urlString
        lastModifiedLabel.text = "Last Modified: " + lastModifiedString!
        
        for label in 0 ..< openingTimesLabels!.count {
            if openingTimesArr![label] != "" {
                openingTimesLabels[label].text = openingTimesArr![label]
            }
            
            else {
                openingTimesLabels[label].text = "Closed" //fills in gap where shop is not open on certain day, lets user know there is no opening times instead of looking unfinished
            }
        }
        
        if amenitiesArr?.count == 0 {
            amenitiesTextView.text = "No amenities availabe for this venue."
            amenitiesTextView.textAlignment = .center
        }
        
        else {
            amenitiesString = (amenitiesArr?.joined(separator: ", "))!
            amenitiesTextView.text = "Amenities:\n\(amenitiesString)."
        }
    }
    
    //fills in button images based on user selection
    func setBtnImages(array: [Bool]) {
        if array[0] == false {
            opinionBtns[0].setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        }
        
        else {
            opinionBtns[0].setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        
        if array[1] == false {
            opinionBtns[1].setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        }
        
        else {
            opinionBtns[1].setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        }
        
        if array[2] == false {
            opinionBtns[2].setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        
        else {
            opinionBtns[2].setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
    }
}
