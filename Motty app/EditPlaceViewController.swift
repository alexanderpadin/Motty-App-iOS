//
//  EditPlaceViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 10/25/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import MapKit

class EditPlaceViewController: UIViewController {

    @IBOutlet weak var categoryParentView: UIView!
    @IBOutlet weak var noteParrentView: UIView!
    @IBOutlet weak var addressParrentView: UIView!
    @IBOutlet weak var nameParentView: UIView!
    @IBOutlet weak var pickerParent: UIView!
    
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        addressBorder.frame = CGRect(x: 0, y:
            self.addressParrentView.frame.size.height, width: self.addressParrentView.frame.size.width, height: width)
        self.addressParrentView.layer.addSublayer(addressBorder)
        
        //Note Input border
        let noteBorder = CALayer()
        noteBorder.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 2.0).CGColor
        noteBorder.frame = CGRect(x: 0, y: self.noteParrentView.frame.size.height, width: self.noteParrentView.frame.size.width, height: width)
        self.noteParrentView.layer.addSublayer(noteBorder)
        
//        
//        //Save button
//        self.saveButton.layer.cornerRadius = 3.0
//        self.saveButton.layer.shadowOffset = CGSize(width: 2, height: 2)
//        self.saveButton.layer.shadowOpacity = 0.3
//        self.saveButton.layer.shadowRadius = 3.0
        
    }

    
    @IBAction func closePicker(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func addNewFolder(sender: AnyObject) {
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
