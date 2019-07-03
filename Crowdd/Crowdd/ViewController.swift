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
    var ref : DatabaseReference!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    @IBOutlet weak var MapView: MKMapView!
    
    struct UserVars{
        static var name = "Kieran"
        static var uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ERROR"
        static var active = false
        static var code = ""
        static var lat = 0.0
        static var long = 0.0
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref =  Database.database().reference()
        
        // Do any additional setup after loading the view.
        checkLocationServices()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    
    @IBAction func CreateGroupBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popUp = storyBoard.instantiateViewController(withIdentifier: "CreateGroup")
        self.present(popUp, animated: true, completion: nil)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            MapView.setRegion(region, animated: true)
        }
    }
    
    func addPin(lat: Double, long: Double){
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        MapView.addAnnotation(annotation1)
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
    
    
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
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        MapView.setRegion(region, animated: true)
        UserVars.lat = location.coordinate.latitude
        UserVars.long = location.coordinate.latitude
        if UserVars.active == true {
            ref.child(ViewController.UserVars.code).child(ViewController.UserVars.uuid).updateChildValues(["lat":ViewController.UserVars.lat,"long":ViewController.UserVars.long])
        }
        print("locations = \(locations)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

