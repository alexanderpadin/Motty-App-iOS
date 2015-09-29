//
//  FirstViewController.swift
//  Motty
//
//  Created by Alexander Padin on 9/24/15.
//  Copyright © 2015 Motty All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*  Set view rounded corners  */
        locationView.layer.cornerRadius = 25.0
        searchView.layer.cornerRadius = 8.0
        
        /*  Hide keyboard onTap  */
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        /*  Initial map location  */
        let initialLocation = CLLocation(latitude: 42.36, longitude: -71.06)
        centerMapOnLocation(initialLocation)
        
        /*  Prepare CLLocation object  */
        _LOCATION_MANAGER.delegate = self
        _LOCATION_MANAGER.desiredAccuracy = kCLLocationAccuracyBest
        _LOCATION_MANAGER.requestWhenInUseAuthorization()
        _LOCATION_MANAGER.distanceFilter = _REGION_RADIUS
        
        self.mapView.delegate = self
    }
   
    /*  Hide search bar */
    override func viewDidAppear(animated: Bool) {
        _ACTUAL_POS = (self.searchView.center.y !=  0) ? self.searchView.center.y : _ACTUAL_POS
        self.searchView.center.y =  0
        _SEARCH_HIDDEN = true
    }
  
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
        //..Do Nothing
    }
    
    /*  Causes the view (or one of its embedded text fields) to resign the first responder status  */
    func DismissKeyboard(){
        view.endEditing(true)
    }

    /*  Not sure if this method is needed  */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewPlace(sender: AnyObject) {
        
        //Save new place.
        
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude
        
        let alertController = UIAlertController(
            title: "New Place Added",
            message: "Latitude: \(lat) \n Longitude: \(lon)",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: { action in })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
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
    
}

