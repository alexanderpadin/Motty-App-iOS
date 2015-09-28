//
//  FirstViewController.swift
//  Motty app
//
//  Created by Alexander Padin on 9/24/15.
//  Copyright © 2015 Alexander Padin. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class FirstViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private let _REGION_RADIUS: CLLocationDistance = 35000;
    private let _REGION_RADIUS_ZOOMED: CLLocationDistance = 500;
    private var _SEARCH_HIDDEN = true;
    private var _ACTUAL_POS: CGFloat = 0;
    private let _LOCATION_MANAGER = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        /*  Set view rounded corners  */
        locationView.layer.cornerRadius = 25.0;
        searchView.layer.cornerRadius = 8.0;
        
        _ACTUAL_POS = self.searchView.center.y;
        
        /*  Hide keyboard onTap  */
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard");
        view.addGestureRecognizer(tap);
        
        /*  Initial map location  */
        let initialLocation = CLLocation(latitude: 42.36, longitude: -71.06);
        centerMapOnLocation(initialLocation);
        
        _LOCATION_MANAGER.delegate = self;
        _LOCATION_MANAGER.desiredAccuracy = kCLLocationAccuracyBest;
        _LOCATION_MANAGER.requestWhenInUseAuthorization();
        _LOCATION_MANAGER.distanceFilter = _REGION_RADIUS;        
    }
    
    /*  Hide search bar */
    override func viewDidAppear(animated: Bool) {
        self.searchView.center.y =  0;
        _SEARCH_HIDDEN = true;
    }
  
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            print("Authorization status changed to \(status.rawValue)")
            switch status {
            case .Authorized, .AuthorizedWhenInUse:
                locateUserInMap();
                
            default:
                _LOCATION_MANAGER.stopUpdatingLocation()
            }
    }
    
    func locateUserInMap() {
        _LOCATION_MANAGER.startUpdatingLocation();
        
        let lat = (_LOCATION_MANAGER.location?.coordinate.latitude)
        let lon = (_LOCATION_MANAGER.location?.coordinate.longitude)
        
        if(lat != nil && lon != nil) {
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(
                CLLocation(
                    latitude: lat!,
                    longitude: lon!).coordinate,
                _REGION_RADIUS_ZOOMED * 2.0, _REGION_RADIUS_ZOOMED * 2.0), animated: true);
        } else {
            
            let alertController = UIAlertController(
                title: "Cannot get location",
                message: "Sorry, there was an error getting device location.",
                preferredStyle: .Alert
            )
            
            let okAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { action in })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)

        }
        
    }
    
    @IBAction func locationButtonOnClick(sender: AnyObject) {
        locateUserInMap();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(textField.text!) { (placemarks, error) -> Void in
            
            if let firstPlacemark = placemarks?[0] {
                print(firstPlacemark.location?.coordinate)
                
                let loc = CLLocation(
                    latitude: (firstPlacemark.location?.coordinate.latitude)!,
                    longitude: (firstPlacemark.location?.coordinate.longitude)!);
                
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(
                    loc.coordinate, self._REGION_RADIUS_ZOOMED * 2.0, self._REGION_RADIUS_ZOOMED * 2.0);
                self.mapView.setRegion(coordinateRegion, animated: true);
            }   
        }
        
        return true;
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
            let errorType = error.code == CLError.Denied.rawValue ? "Access Denied"
                : "Error \(error.code)"
            let alertController = UIAlertController(title: "Error getting device location.",
                message: errorType, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { action in })
            alertController.addAction(okAction)
            presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*  Toggle Search bar onclick  */
    @IBAction func toggleSearchBar(sender: AnyObject) {
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseOut, animations: {
            if(self._SEARCH_HIDDEN) {
                //Show search bar
                self.searchView.center.y = self._ACTUAL_POS;
                self._SEARCH_HIDDEN = !self._SEARCH_HIDDEN;
            } else {
                //Hide search bar
                self.searchView.center.y = 0;
                self._SEARCH_HIDDEN = !self._SEARCH_HIDDEN;
                }
            }, completion: { finished in
                //Do nothing.
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(
            location.coordinate, _REGION_RADIUS * 2.0, _REGION_RADIUS * 2.0);
        mapView.setRegion(coordinateRegion, animated: true);
    }
    
    /*  Causes the view (or one of its embedded text fields) to resign the first responder status  */
    func DismissKeyboard(){
        view.endEditing(true);
    }

    /*  Not sure if this method is needed  */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }

}

