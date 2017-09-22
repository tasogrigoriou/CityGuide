//
//  LocationViewController.swift
//  CityGuide
//
//  Created by Anastasios Grigoriou on 9/20/17.
//  Copyright © 2017 Grigoriou. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class LocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var manager = CLLocationManager()
  var chosenLatitude = ""
  var chosenLongitude = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()

    let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.pressGesture(gestureRecognizer:)))
    recognizer.minimumPressDuration = 1
    mapView.addGestureRecognizer(recognizer)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    chosenLatitude = ""
    chosenLongitude = ""
  }
  
  @objc func pressGesture(gestureRecognizer: UIGestureRecognizer) {
    print("gesture recognized")
    
    if gestureRecognizer.state == UIGestureRecognizerState.began {
      let touches = gestureRecognizer.location(in: mapView)
      let coordinates = mapView.convert(touches, toCoordinateFrom: mapView)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinates
      annotation.title = globalName
      annotation.subtitle = globalType
      
      mapView.addAnnotation(annotation)
      
      chosenLatitude = String(coordinates.latitude)
      chosenLongitude = String(coordinates.longitude)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
    
    manager.stopUpdatingLocation()
    
    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    let region = MKCoordinateRegion(center: location, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveButtonClicked(_ sender: Any) {
    
    let object = PFObject(className: "Places")
    object["name"] = globalName
    object["type"] = globalType
    object["atmosphere"] = globalAtmosphere
    object["latitude"] = chosenLatitude
    object["longitude"] = chosenLongitude
    
    if let imageData = UIImageJPEGRepresentation(globalImage, 0.5) {
      object["image"] = PFFile(name: "image.jpg", data: imageData)
    }
    
    object.saveInBackground { (success, error) in
      if error != nil {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
      } else {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlace"), object: nil)
        self.performSegue(withIdentifier: "fromLocationToPlacesVC", sender: nil)
      }
    }
    
  }
  
}
