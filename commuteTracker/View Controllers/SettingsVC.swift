//
//  CurrentTrip.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/22/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class SettingsVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var startingAddress: UITextField!
    @IBOutlet weak var destinationAddress: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var commuteInfoView: UIView!
    
    @IBOutlet weak var morningStartingAddressLabel: UILabel!
    @IBOutlet weak var morningEndingAddressLabel: UILabel!
    @IBOutlet weak var eveningStartingAddressLabel: UILabel!
    @IBOutlet weak var eveningEndingAddressLabel: UILabel!
    
    
    var tripInProgress = false
    var startingLat = 0.0
    var startingLon = 0.0
    var destinationLat = 0.0
    var destinationLon = 0.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    override func viewDidLoad(){
        super.viewDidLoad()
        searchButton.layer.cornerRadius = 5
        searchIndicator.isHidden = true
        successImage.isHidden = true
        startingAddress.delegate = self
        destinationAddress.delegate = self
        startingAddress.autocorrectionType = .no
        destinationAddress.autocorrectionType = .no
        startingAddress.autocapitalizationType = .none
        destinationAddress.autocapitalizationType = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        searchIndicator.isHidden = true
        successImage.isHidden = true
        commuteInfoView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        destinationAddress.resignFirstResponder()
        startingAddress.resignFirstResponder()
        successImage.isHidden = true
        searchIndicator.isHidden = false
        searchIndicator.startAnimating()
        
        if startingAddress.text!.isEmpty{
            displayAlert(title: "Starting Address is empty", message: "Please enter a valid location")
            searchIndicator.isHidden = true
            searchIndicator.stopAnimating()
        }else if destinationAddress.text!.isEmpty{
            displayAlert(title: "Destination Address is empty", message: "Please enter a valid location")
            searchIndicator.isHidden = true
            searchIndicator.stopAnimating()
        }else{

            geocodeLocations(startingAddress: startingAddress.text!, destinationAddress: destinationAddress.text!)
        }
        
    }
    
    
    func geocodeLocations(startingAddress: String, destinationAddress: String){
        
        //starting location search
        CLGeocoder().geocodeAddressString(startingAddress) { (placemarks, error) in
        guard error == nil else{
        self.displayAlert(title: "Error", message: "Unable to find starting address")
            self.searchIndicator.isHidden = true
            self.searchIndicator.stopAnimating()
        return
        }
        
        if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                if let location = placemark.location {
                let coordinate = location.coordinate
                    UserDefaults.standard.set(coordinate.latitude, forKey: "startingLatitude")
                    UserDefaults.standard.set(coordinate.longitude, forKey: "startingLongitude")
                    UserDefaults.standard.set(startingAddress, forKey: "startingAddressString")
                    self.searchIndicator.isHidden = true
                    self.searchIndicator.stopAnimating()
                    self.successImage.isHidden = false
                    self.commuteInfoView.isHidden = false
                    self.morningStartingAddressLabel.text = startingAddress
                    self.eveningEndingAddressLabel.text = startingAddress
                }
            }
        }
        //destination location search
        CLGeocoder().geocodeAddressString(destinationAddress) { (placemarks, error) in
            guard error == nil else{
                self.displayAlert(title: "Error", message: "Unable to find destination address")
                self.searchIndicator.isHidden = true
                self.searchIndicator.stopAnimating()
                return
            }
            
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                if let location = placemark.location {
                    let coordinate = location.coordinate
                    UserDefaults.standard.set(coordinate.latitude, forKey: "destinationLatitude")
                    UserDefaults.standard.set(coordinate.longitude, forKey: "destinationLongitude")
                    UserDefaults.standard.set(destinationAddress, forKey: "destinationAddressString")
                    self.searchIndicator.isHidden = true
                    self.searchIndicator.stopAnimating()
                    self.successImage.isHidden = false
                    self.commuteInfoView.isHidden = false
                    self.morningEndingAddressLabel.text = destinationAddress
                    self.eveningStartingAddressLabel.text = destinationAddress
                }
            }
        }
    }
    
    
    
   
    //UI TextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
}
