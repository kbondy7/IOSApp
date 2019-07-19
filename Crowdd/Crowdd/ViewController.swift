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
    @IBOutlet weak var Group: UILabel!
    
    let defaults = UserDefaults.standard
    
    
//    Global variables
    struct UserVars{
        static var name = UserDefaults.standard.string(forKey: "name")
        static var firstInitial = UserDefaults.standard.string(forKey: "firstInitial")
        static var lastInitial = UserDefaults.standard.string(forKey: "lastInitial")

        static var uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ERROR"
        static var active = false
        static var code = ""
        static var coords = [0.0, 0.0]
        static var friends = Dictionary<String,[Double]>()
        static var pins = [MKPointAnnotation]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapView.delegate = self
        
        ref =  Database.database().reference()
        
//        Timer
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.populates), userInfo: nil, repeats: true)
//        Location services
        checkLocationServices()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!defaults.bool(forKey: "FirstTime"))
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popUp = storyBoard.instantiateViewController(withIdentifier: "OnBoard")
            self.present(popUp, animated: true, completion: nil)
        }
        if(UserVars.active == true){
            populates()
            Group.text = UserVars.code
            
        }
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
            Group.text = "Inactive"
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
    
    func getInitials(name:NSString) -> NSString{
        
        var strArray = name.components(separatedBy: " ");
        
        let firstInitial = strArray[0].prefix(1)
        let lastInitial = strArray[1].prefix(1)
        
        return firstInitial + lastInitial as NSString
        
    }
    
// Building Annotation Images
    func createAnnotations(inImage:UIImage, atPoint:CGPoint) -> UIImage{
        //let initials = UserVars.firstInitial + UserVars.lastInitial
        
        for (name, coords) in UserVars.friends{
            let drawText = getInitials(name: name as NSString)
            
            let textColor = UIColor.red
            let textFont = UIFont(name: "Helvetica Bold", size: 12)!
            
            
            // Setup the image context using the passed image
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
            
            // Setup the font attributes that will be later used to dictate how the text should be drawn
            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor,
            ]
            
            inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
            
            // Create a point within the space that is as bit as the image
            let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
            
            // Draw the text into an image
            drawText.draw(in: rect, withAttributes: textFontAttributes)
            
            // Create a new image out of the images we have created
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            
            // End the context now that we have the image we need
            UIGraphicsEndImageContext()
            
            //Pass the image back up to the caller
            return newImage

        }
        print("didn't work");
        return inImage
    }
    
//    Populating the other people in your group
    @objc func populates(){
        if (UserVars.active){
            if(Group.text == "Inactive"){
                Group.text = UserVars.code
            }
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
                    if(pin.subtitle == name){
                        pin.coordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
                        found = true
                    }
                }
                if(!found){
                    let createpoint = MKPointAnnotation()
                    createpoint.subtitle = name
                    createpoint.coordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
                    UserVars.pins.append(createpoint)
                    MapView.addAnnotation(createpoint)
                }
            }
        }
    
    }
}


//Annotation Images
extension ViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let newImage = createAnnotations(inImage: UIImage(named:"friendLocation-1")!, atPoint: CGPoint(x: 20, y: 20))
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        if annotation === mapView.userLocation{
            annotationView?.image = UIImage(named: "userLoc")
        } else {
            annotationView?.image = newImage
        }
        
        annotationView?.canShowCallout = true;
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation was selected")
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

