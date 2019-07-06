//
//  ViewController.swift
//  Crowdd
//
//  Created by Kieran Bondy on 6/27/19.
//  Copyright © 2019 Kieran Bondy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation


class ViewController: UIViewController {
//    Variable declarations
    var ref : DatabaseReference!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    var timer = Timer()
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var StartBtn: UIButton!
    
//    Global variables
    struct UserVars{
        static var name = "Doug"
        static var uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ERROR"
        static var active = false
        static var code = ""
        static var coords = [0.0, 0.0]
        static var friends = Dictionary<String,[Double]>()
        static var pins = [MKPointAnnotation]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref =  Database.database().reference()
        if(UserVars.active == true){
            populates()
            
            
        }
//        Timer
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.populates), userInfo: nil, repeats: true)
//        Location services
        checkLocationServices()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    
    
    @IBAction func ProfileBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let Home = storyBoard.instantiateViewController(withIdentifier: "Profile")
        self.present(Home, animated: true, completion: nil)
    }
    
    
//    Takes you to the group page
    @IBAction func CreateGroupBtn(_ sender: UIButton) {
        if(UserVars.active)
        {
            UserVars.active = false
            StartBtn.backgroundColor = UIColor(displayP3Red: 0, green: 1.0, blue: 0, alpha: 1)
            if(UserVars.friends.count == 0){
                ref.child(UserVars.code).removeValue()
            }
            else{
                ref.child(UserVars.code).child(UserVars.uuid).removeValue()
            }
        }
        else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popUp = storyBoard.instantiateViewController(withIdentifier: "CreateGroup")
            self.present(popUp, animated: true, completion: nil)
        }
    }
    
//    Location set up
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
//    Centering on user
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            MapView.setRegion(region, animated: true)
        }
    }
    
//    Checking permission for location
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
//    Checking authorization
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            MapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
            
        }
    }
    
//    Populating the other people in your group
    @objc func populates(){
        if (UserVars.active){
            StartBtn.backgroundColor = UIColor(displayP3Red: 1.0, green: 0, blue: 0, alpha: 1)
//            Updating friends array
            ref.child(UserVars.code).observe(DataEventType.value) { (snapshot) in
                let update = snapshot.value as? [String : AnyObject] ?? [:]
                if(UserVars.friends.count > update.count-1){
                    for (name, _) in UserVars.friends{
                        var found = false
                        for (id, data) in update {
                            if(data["name"] as! String == name){
                                found = true
                            }
                            if(id != UserVars.uuid){
                                UserVars.friends[data["name"] as! String] = data["coords"] as? [Double]
                            }
                        }
                        if(!found){
                            for annotation in self.MapView.annotations{
                                if(annotation.title == name){
                                    self.MapView.removeAnnotation(annotation)
                                }
                            }
                            
                            UserVars.friends.removeValue(forKey: name)
                        }
                    }
                }
                else{
                    for (id, data) in update {
                        if(id != UserVars.uuid){
                            UserVars.friends[data["name"] as! String] = data["coords"] as? [Double]
                        }
                    }
                }
                
            }
           
            ref.child(ViewController.UserVars.code).child(ViewController.UserVars.uuid).updateChildValues(["coords":ViewController.UserVars.coords])
//          Creating annotations
            for (name, coords) in UserVars.friends{
                var found = false
                for pin in UserVars.pins{
                    if(pin.title == name){
                        pin.coordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
                        found = true
                    }
                }
                if(!found){
                    let createpoint = MKPointAnnotation()
                    createpoint.title = name
                    createpoint.coordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
                    UserVars.pins.append(createpoint)
                    MapView.addAnnotation(createpoint)
                }
            }
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        //MapView.setRegion(region, animated: true)
        UserVars.coords[0] = location.coordinate.latitude
        UserVars.coords[1] = location.coordinate.longitude
        if (UserVars.active == true){
            ref.child(UserVars.code).child(UserVars.uuid).updateChildValues(["coords":UserVars.coords])
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

