//
//  PlacesViewController.swift
//  CityGuide
//
//  Created by Anastasios Grigoriou on 9/20/17.
//  Copyright © 2017 Grigoriou. All rights reserved.
//

import UIKit
import Parse

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  var placeNameArray = [String]()
  var placeTypeArray = [String]()
  var tappedPlace = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    getDataFromServer()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.getDataFromServer), name: NSNotification.Name(rawValue: "newPlace"), object: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromPlacesToDetailsVC" {
      let destinationVC = segue.destination as! DetailsViewController
      destinationVC.chosenPlace = tappedPlace
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tappedPlace = placeNameArray[indexPath.row]
    self.performSegue(withIdentifier: "fromPlacesToDetailsVC", sender: nil)
  }
  
  @objc func getDataFromServer() {
    let query = PFQuery(className: "Places")
    
    query.findObjectsInBackground { (objects, error) in
      if error != nil {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
      } else {
        self.placeNameArray.removeAll(keepingCapacity: false)
        self.placeTypeArray.removeAll(keepingCapacity: false)
        
        for object in objects! {
          self.placeNameArray.append(object.object(forKey: "name") as! String)
          self.placeTypeArray.append(object.object(forKey: "type") as! String)
        }
        
        self.tableView.reloadData()
      }
      
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = placeNameArray[indexPath.row]
    cell.detailTextLabel?.text = placeTypeArray[indexPath.row]
    
    cell.backgroundColor = UIColor.clear
    cell.textLabel?.textColor = UIColor.init(white: 0.9, alpha: 0.9)
    cell.detailTextLabel?.textColor = UIColor.lightGray
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placeNameArray.count
  }
  
  @IBAction func addButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "fromPlacesToAttributesVC", sender: nil)
  }
  
  @IBAction func logoutButtonClicked(_ sender: Any) {
    
    PFUser.logOutInBackground { (error) in
      if error != nil {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
      } else {
        UserDefaults.standard.removeObject(forKey: "userloggedin")
        UserDefaults.standard.synchronize()
        
        let signUpController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpViewController
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = signUpController
        
        delegate.rememberLogin()
        
      }
    }
    
  }
   
}

