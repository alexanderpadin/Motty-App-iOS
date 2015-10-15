//
//  addPlaceViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 10/11/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import MapKit

class addPlaceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private let _REGION_RADIUS: CLLocationDistance = 1000
    
    @IBOutlet weak var segueMapView: MKMapView!
    
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var noteTextView: UITextField!
    @IBOutlet weak var addresTextView: UITextField!
    @IBOutlet weak var folderPicker: UIPickerView!
    
    @IBOutlet weak var nameParentView: UIView!
    @IBOutlet weak var addressParentView: UIView!
    @IBOutlet weak var noteParentView: UIView!
    @IBOutlet weak var folderParentView: UIView!
   
    @IBOutlet weak var mapUpperShadow: UIView!
    @IBOutlet weak var mapLowerShadow: UIView!
    
    var placeLat : CLLocationDegrees = 0.0
    var placeLon : CLLocationDegrees = 0.0
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextView.delegate = self
        self.noteTextView.delegate = self
        self.addresTextView.delegate = self
        
        //Hide keyboard onTap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //pickerData = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
        self.folderPicker.delegate = self
        self.folderPicker.dataSource = self
        
        mapUpperShadow.layer.shadowOffset = CGSize(width: 3, height: 3)
        mapUpperShadow.layer.shadowOpacity = 0.3
        mapUpperShadow.layer.shadowRadius = 2
        
        mapLowerShadow.layer.shadowOffset = CGSize(width: 3, height: -3)
        mapLowerShadow.layer.shadowOpacity = 0.3
        mapLowerShadow.layer.shadowRadius = 2
        
        let initialLocation = CLLocation(latitude: placeLat as Double, longitude: placeLon as Double)
        centerMapOnLocation(initialLocation)
    
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: placeLat, longitude: placeLon)
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
                //Do nothing
            }
        }

    }
    
    override func viewDidLayoutSubviews() {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        prepareView()
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        //UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle: UIStatusBarStyle, animated: <#T##Bool#>)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func savePlacePressed(sender: AnyObject) {
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func DismissKeyboard(){
        //Hide keyboard
        view.endEditing(true)
    }
    
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
        
//        let folderBorder = CALayer()
//        folderBorder.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 2.0).CGColor
//        folderBorder.frame = CGRect(x: 0, y: self.folderParentView.frame.size.height, width: self.folderParentView.frame.size.width, height: width)
//        self.folderParentView.layer.addSublayer(folderBorder)

    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, _REGION_RADIUS * 2.0, _REGION_RADIUS * 2.0)
        segueMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
