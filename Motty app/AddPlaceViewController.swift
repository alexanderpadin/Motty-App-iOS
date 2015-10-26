//
//  addPlaceViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 10/11/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class addPlaceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private let _REGION_RADIUS: CLLocationDistance = 500
    
    @IBOutlet weak var segueMapView: MKMapView!
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var noteTextView: UITextField!
    @IBOutlet weak var addresTextView: UITextField!
    @IBOutlet weak var folderPicker: UIPickerView!
    @IBOutlet weak var folderTextView: UITextField!
    
    @IBOutlet weak var nameParentView: UIView!
    @IBOutlet weak var addressParentView: UIView!
    @IBOutlet weak var noteParentView: UIView!
    @IBOutlet weak var folderParentView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    var placeLat : CLLocationDegrees = 0.0
    var placeLon : CLLocationDegrees = 0.0
    var pickerData: [String] = [String]()
    var folderArray:[(name: String, ID: String)] = []
    
    private var appDelagate: AppDelegate = AppDelegate()
    private var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    private var result : [AnyObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set View Delegate
        self.nameTextView.delegate = self
        self.noteTextView.delegate = self
        self.addresTextView.delegate = self
        self.folderTextView.delegate = self
        self.folderPicker.delegate = self
        self.folderPicker.dataSource = self
    
        //Set keyboard onTap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //Get AppDelegate Context
        appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelagate.managedObjectContext
        
        //Center Map in location selected
        centerMapOnLocation(CLLocation(latitude: placeLat as Double, longitude: placeLon as Double))
        
        //Set AddressTextView content
        getAddress(placeLat, lon: placeLon)
        
    }
    
    override func viewDidLayoutSubviews() {
        //UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        prepareView()
    }
    
    
    /*  Hide keyboard  */
    func DismissKeyboard(){
        //Hide keyboard
        view.endEditing(true)
    }
    
    /*  Prepare view style  */
    func prepareView() -> Void {
        let width = CGFloat(1.0)
    
        //Name Input border
        let nameBorder = CALayer()
        nameBorder.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 2.0).CGColor
        nameBorder.frame = CGRect(x: 0, y: self.nameParentView.frame.size.height, width: self.nameParentView.frame.size.width, height: width)
        self.nameParentView.layer.addSublayer(nameBorder)
        
        //Address Input border
        let addressBorder = CALayer()
        addressBorder.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 2.0).CGColor
        addressBorder.frame = CGRect(x: 0, y: self.addressParentView.frame.size.height, width: self.addressParentView.frame.size.width, height: width)
        self.addressParentView.layer.addSublayer(addressBorder)
        
        //Note Input border
        let noteBorder = CALayer()
        noteBorder.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 2.0).CGColor
        noteBorder.frame = CGRect(x: 0, y: self.noteParentView.frame.size.height, width: self.noteParentView.frame.size.width, height: width)
        self.noteParentView.layer.addSublayer(noteBorder)
        
        
        //Save button
        self.saveButton.layer.cornerRadius = 3.0
        self.saveButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.saveButton.layer.shadowOpacity = 0.3
        self.saveButton.layer.shadowRadius = 3.0
        
        //Picker View
        self.folderPicker.layer.cornerRadius = 3.0
        //Map View
        self.segueMapView.layer.cornerRadius = 3.0
    }
    
    /*  Get Addres from coordenates and set textview  */
    func getAddress(lat: Double, lon: Double) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat as Double, longitude: lon as Double)
        var newAddress = ""
        
        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks as [CLPlacemark]!
                where placemarks.count > 0 {
                    for item in placemarks[0].addressDictionary?["FormattedAddressLines"] as! NSArray {
                        newAddress += (newAddress == "") ? "\(item)" : ", \(item)"
                    }
                    self.addresTextView.text = newAddress
            } else {
                self.addresTextView.text = ""
            }
        }
    }

    /*  Center Map to location selected  */
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, _REGION_RADIUS * 0.5, _REGION_RADIUS * 0.5)
        segueMapView.setRegion(coordinateRegion, animated: true)
    }
    

    /*  Insert new data to the db  */
    func insertData(placeName: String, placeX: Double, placeY: Double, placeAddress: String, folderIndex: Int, placeNote: String) {
        
        //Cannot send dta with actual address, usally is ready when segue is up, in case isnt the function is no executed.
        if(placeAddress == "") {
            return
        }
    
        let nameOfPlace = (placeName == "") ? "Unamed" : placeName
        let IdOfPlace = nameOfPlace + "_\(Int(arc4random_uniform(99999999)))"
        let folderId = folderArray[folderIndex].1
        let newPlace = NSEntityDescription.insertNewObjectForEntityForName("Places",
                inManagedObjectContext: context) as NSManagedObject
    
        newPlace.setValue(IdOfPlace, forKey: "placeId")
        newPlace.setValue(nameOfPlace, forKey: "placeName")
        newPlace.setValue(placeAddress, forKey: "placeAddress")
        newPlace.setValue(folderId, forKey: "folderId")
        newPlace.setValue(placeNote, forKey: "placeNote")
        newPlace.setValue(placeX, forKey: "placeX")
        newPlace.setValue(placeY, forKey: "placeY")
        
        do {
            try context.save()
            print("Success")
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch _ {
            print("Error")
        }
        
    }
    
    
    /*********************************************************************
        Picker functions
    **********************************************************************/
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        //let myTitle = NSAttributedString(string: titleData, attributes:
        //[NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,
        //NSForegroundColorAttributeName:UIColor(red: 223.0/255, green: 0.0/255, blue: 23.0/255, alpha: 1.0)])
        
        let myTitle = NSAttributedString(string: titleData, attributes:
            [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,
                NSForegroundColorAttributeName:UIColor(red: 0.0/255,
                    green: 0.0/255, blue: 0.0/255, alpha: 1.0)])
        
        return myTitle
    }
    
    // When picker view is changed
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.folderTextView.text = self.pickerData[ self.folderPicker.selectedRowInComponent(0)]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    /*********************************************************************
        ./Picker functions
    **********************************************************************/
    
    
    /*********************************************************************
        Keyboard functions
    **********************************************************************/
    
    /*  Handle when textviews are pressed  */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //If folder view is presses avoid keyboard prompt
        if(textField.tag == 1) {
            //Hide keyboard
            view.endEditing(true)
            
            if(self.folderPicker.alpha != 1.0) {
                self.folderPicker.transform = CGAffineTransformMakeScale(1.0, 0.0)
                self.folderPicker.alpha = 1.0
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.folderPicker.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }, completion: { finished in
                        self.folderTextView.text = self.pickerData[ self.folderPicker.selectedRowInComponent(0)]
                })
            } else {
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                   
                    self.folderPicker.alpha = 0.0
            
                    }, completion: { finished in
                        
                        self.folderTextView.text = self.pickerData[ self.folderPicker.selectedRowInComponent(0)]
                })
            }
            
            return false
        } else {
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.folderPicker.alpha = 0.0
                }, completion: { finished in
                    //Do Nothing.
            })
            return true
        }
    }
    
    /*  Close keyboard when return is pressed  */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    /*********************************************************************
        ./Keyboard functions
    **********************************************************************/
    
    
    /*********************************************************************
        Action Outlets
    **********************************************************************/
    
    /*  Triggered when cancel button is pressed  */
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*  Triggered when save button is pressed  */
    @IBAction func savePlacePressed(sender: AnyObject) {
        insertData(nameTextView.text!, placeX: placeLat, placeY: placeLon,
            placeAddress: addresTextView.text!, folderIndex: self.folderPicker.selectedRowInComponent(0), placeNote: noteTextView.text!)
    }
    /*********************************************************************
        ./Action Outlets
    **********************************************************************/
}
