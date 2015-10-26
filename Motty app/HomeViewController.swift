//
//  HomeViewController.swift
//  Motty
//
//  Created by Alexander Padin on 9/24/15.
//  Copyright © 2015 Motty All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI
import CoreData

class FirstViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchView: UIView!                                            
    @IBOutlet weak var pinView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    private let _REGION_RADIUS: CLLocationDistance = 1000
    private var _SEARCH_HIDDEN = true
    private var _ACTUAL_POS: CGFloat = 0
    private let _LOCATION_MANAGER = CLLocationManager()
    
    private var appDelagate: AppDelegate = AppDelegate()
    private var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    private var result : [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set preconf file if needed.
        if(ifFirstTimeRunning()) {
            insertDefaultCategory()
            NSUserDefaults.standardUserDefaults().setValue("NO", forKey: "FirstTime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        //Hide keyboard onTap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //Initial map location
        self.mapView.delegate = self
        let initialLocation = CLLocation(latitude: 42.36, longitude: -71.06)
        centerMapOnLocation(initialLocation)
        
        //Prepare CLLocation object
        _LOCATION_MANAGER.delegate = self
        _LOCATION_MANAGER.desiredAccuracy = kCLLocationAccuracyBest
        _LOCATION_MANAGER.requestWhenInUseAuthorization()
        _LOCATION_MANAGER.distanceFilter = _REGION_RADIUS
        
        //Get AppDelegate Context
        appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelagate.managedObjectContext
    }
    
    /*  Called after view appear  */
    override func viewDidAppear(animated: Bool) {
        //Set views
        searchView.layer.cornerRadius = 5.0
        searchView.layer.shadowOffset = CGSize(width: 1, height: 1)
        searchView.layer.shadowOpacity = 0.1
        searchView.layer.shadowRadius = 5.0
        locationButton.layer.cornerRadius = 5.0
        locationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        locationButton.layer.shadowOpacity = 0.1
        locationButton.layer.shadowRadius = 5.0
    }
    
    /*  Verify if app is runned for the first time  */
    func ifFirstTimeRunning() -> Bool{
        if(NSUserDefaults.standardUserDefaults().objectForKey("FirstTime") == nil) {
            return true
        } else {
            return false
        }
    }
    
    /*  Set status bar text color  */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /* Called right before the segue is launched  */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addPlaceSegue") {
            
            //Variables to be transfered to segue
            let destinationViewCOntroller : addPlaceViewController = segue.destinationViewController as! addPlaceViewController
            destinationViewCOntroller.placeLat = mapView.centerCoordinate.latitude
            destinationViewCOntroller.placeLon = mapView.centerCoordinate.longitude
            var arrayOfFolders:[(name: String, ID: String)] = []
            var arrayForPicker: [String] = [String]()
            
            //Read Folders table
            let request = NSFetchRequest(entityName: "Folders")
            request.resultType = NSFetchRequestResultType.DictionaryResultType
            
            //Get folders name and IDs from db
            do {
                result = [AnyObject]()
                result = try context.executeFetchRequest(request)
                for folders in result! {
                    arrayForPicker.append(folders.valueForKey("folderName") as! String)
                    arrayOfFolders.append(name: folders.valueForKey("folderName") as! String, ID: folders.valueForKey("folderId") as! String)
                }
         
                destinationViewCOntroller.pickerData = arrayForPicker
                destinationViewCOntroller.folderArray = arrayOfFolders
            } catch _ {
                let AlertController = UIAlertController(
                    title: "ERROR",
                    message: "Error displaying data.",
                    preferredStyle: .Alert)
                
                AlertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(AlertController, animated: true, completion: nil)
            }
        }
    }

    /*  Insert default folder if missing  */
    func insertDefaultCategory() {
        appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelagate.managedObjectContext
        
        let newFolder = NSEntityDescription.insertNewObjectForEntityForName("Folders",
            inManagedObjectContext: context) as NSManagedObject
    
        newFolder.setValue("Home", forKey: "folderName")
        newFolder.setValue("Home" + "_\(Int(arc4random_uniform(99999999)))", forKey: "folderId")
        newFolder.setValue(6, forKey: "folderNumOfItems")
        newFolder.setValue("home_i", forKey: "folderIcon")
        newFolder.setValue("home_bg", forKey: "folderBackground")
        
        let newFolder2 = NSEntityDescription.insertNewObjectForEntityForName("Folders",
            inManagedObjectContext: context) as NSManagedObject
        
        newFolder2.setValue("Restaurants", forKey: "folderName")
        newFolder2.setValue("Restaurants" + "_\(Int(arc4random_uniform(99999999)))", forKey: "folderId")
        newFolder2.setValue(2, forKey: "folderNumOfItems")
        newFolder2.setValue("restaurants_i", forKey: "folderIcon")
        newFolder2.setValue("restaurants_bg", forKey: "folderBackground")
    
        do {
            try context.save()
            print("Default Category Created")
            
        } catch _ {
            print("Error")
        }
    }


    
    /*********************************************************************
        Keyboard functions
    **********************************************************************/
    
    /*  Causes the view (or one of its embedded text fields) to resign the first responder status  */
    func DismissKeyboard(){
        //Hide keyboard
        view.endEditing(true)
    }
    
    /*  Action Listener on keyboard return click  */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textField.text!) { (placemarks, error) -> Void in
            
            if let firstPlacemark = placemarks?[0] {
                self.centerMapOnLocation(CLLocation(
                    latitude: (firstPlacemark.location?.coordinate.latitude)!,
                    longitude: (firstPlacemark.location?.coordinate.longitude)!
                    ))
            }
        }
        return true;
    }
    /*********************************************************************
        ./Keyboard methods
    **********************************************************************/
  
    
    /*********************************************************************
        Map methods
    **********************************************************************/
    
    /* Get position of device */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .Authorized, .AuthorizedWhenInUse:
                locateUserInMap()
            default:
                _LOCATION_MANAGER.stopUpdatingLocation()
        }
    }
    
    /*  Center map by location and radius  */
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, _REGION_RADIUS * 2.0, _REGION_RADIUS * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    /*  Locate device in map  */
    func locateUserInMap() {
        _LOCATION_MANAGER.startUpdatingLocation()
        
        let lat = (_LOCATION_MANAGER.location?.coordinate.latitude)
        let lon = (_LOCATION_MANAGER.location?.coordinate.longitude)
        
        if(lat != nil && lon != nil) {
            centerMapOnLocation(CLLocation(latitude: lat!, longitude: lon!))
        } else {
            //Do nothing.
        }
    }
    
    /*  Listener onMapRegionChanged  */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        pinView.image = UIImage(named: "pin_placed.png")!
    }
    
    /*  Listener onMapRegionStartChange  */
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        pinView.image = UIImage(named: "pin_hover.png")!
    }
    
    /*  CLLocation Error Handler  */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //..Do Nothing for now.
    }
    /*********************************************************************
        ./Map methods
    **********************************************************************/
    
    
    /*********************************************************************
        Action Outlets
    **********************************************************************/
    
    /*  OnClick on location button  */
    @IBAction func locationButtonOnClick(sender: AnyObject) {
        locateUserInMap()
    }
    /*********************************************************************
        ./Action Outlets
    **********************************************************************/
}

