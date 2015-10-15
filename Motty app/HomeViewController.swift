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
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var pinView: UIImageView!
    
    private let _REGION_RADIUS: CLLocationDistance = 1000
    private var _SEARCH_HIDDEN = true
    private var _ACTUAL_POS: CGFloat = 0
    private let _LOCATION_MANAGER = CLLocationManager()
    private var appDelagate: AppDelegate = AppDelegate()
    private var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    private var result : [AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set view rounded corners
        locationView.layer.cornerRadius = 25.0
        searchView.layer.cornerRadius = 8.0
        
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
        
   //     Get AppDelegate Context
        appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDelagate.managedObjectContext
        
//        
//        let newFolder = NSEntityDescription.insertNewObjectForEntityForName("Folders",
//            inManagedObjectContext: context) as NSManagedObject
//        
//        newFolder.setValue("Restaurants", forKey: "folderName")
//        newFolder.setValue("restaurants", forKey: "folderId")
//        newFolder.setValue(0, forKey: "folderNumOfItems")
//        newFolder.setValue("icon", forKey: "folderIcon")
//        newFolder.setValue("background", forKey: "folderBackground")
//        
//        do {
//            try context.save()
//            let AlertController = UIAlertController(
//                title: "Success",
//                message: "New Folder Saved Successfully.",
//                preferredStyle: .Alert)
//            
//            AlertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(AlertController, animated: true, completion: nil)
//            
//        } catch _ {
//            let AlertController = UIAlertController(
//                title: "Error",
//                message: "Something when wrong saving the new Folder.",
//                preferredStyle: .Alert)
//            
//            AlertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        }
//
        
        
    }
   
    /*  Called after view appear  */
    override func viewDidAppear(animated: Bool) {
         /*  Hide search bar */
        _ACTUAL_POS = (self.searchView.center.y !=  0) ? self.searchView.center.y : _ACTUAL_POS
        self.searchView.center.y =  0
        _SEARCH_HIDDEN = true
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    /* Called right before the segue is launched  */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addPlaceSegue") {
            let destinationViewCOntroller : addPlaceViewController = segue.destinationViewController as! addPlaceViewController
            destinationViewCOntroller.placeLat = mapView.centerCoordinate.latitude
            destinationViewCOntroller.placeLon = mapView.centerCoordinate.longitude
            var arrayOfFolders: [String] = []
            
            let request = NSFetchRequest(entityName: "Folders")
            request.resultType = NSFetchRequestResultType.DictionaryResultType
            
            do {
                result = [AnyObject]()
                result = try context.executeFetchRequest(request)
                
                for folders in result! {
                    arrayOfFolders.append(folders.valueForKey("folderName") as! String)
                }
         
                destinationViewCOntroller.pickerData = arrayOfFolders
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
    
    
    /*********************************************************************
        Keyboard functions
    **********************************************************************/
    
    /*  Causes the view (or one of its embedded text fields) to resign the first responder status  */
    func DismissKeyboard(){
        //Hide keyboard
        view.endEditing(true)
        
        //Hide search bar
        searchView.center.y = 0
        _SEARCH_HIDDEN = true
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
        pinView.image = UIImage(named: "pin_placed")!
        
    }
    
    /*  Listener onMapRegionStartChange  */
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        pinView.image = UIImage(named: "pin_icon")!
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
    
    /*  Toggle Search bar onClick  */
    @IBAction func toggleSearchBar(sender: AnyObject) {
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseOut, animations: {
            self.searchView.center.y = (self._SEARCH_HIDDEN) ? self._ACTUAL_POS : 0
            self._SEARCH_HIDDEN = (self._SEARCH_HIDDEN) ? false : true
            }, completion: { finished in
                //Do nothing.
        })
    }
    /*********************************************************************
        ./Action Outlets
    **********************************************************************/
}

