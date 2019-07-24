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

class CurrentTrip: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var startingAddress: UITextField!
    @IBOutlet weak var destinationAddress: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var successImage: UIImageView!
    
    
    var tripInProgress = false
    var startingLat = 0.0
    var startingLon = 0.0
    var destinationLat = 0.0
    var destinationLon = 0.0
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        startStopButton.layer.cornerRadius = 5
        searchButton.layer.cornerRadius = 5
        searchIndicator.isHidden = true
        successImage.isHidden = true
        startingAddress.delegate = self
        destinationAddress.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
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
    
    @IBAction func stopStartPressed(_ sender: Any) {
        if tripInProgress{ // finish trip
            DispatchQueue.main.async{
                self.startStopButton.setTitle("Start Commute", for: .normal)
            }
            tripInProgress = false
            endTrip()
        }
        else if !tripInProgress{ //start trip
            DispatchQueue.main.async{
                self.startStopButton.setTitle("Finish Commute", for: .normal)
            }
            tripInProgress = true
            startTrip()
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
                    self.startingLat = coordinate.latitude
                    self.startingLon = coordinate.longitude
                    self.searchIndicator.isHidden = true
                    self.searchIndicator.stopAnimating()
                    self.successImage.isHidden = false
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
                    self.destinationLat = coordinate.latitude
                    self.destinationLon = coordinate.longitude
                    self.searchIndicator.isHidden = true
                    self.searchIndicator.stopAnimating()
                    self.successImage.isHidden = false
                }
            }
        }
    }
    
    func getTravelTimeFromGoogle(){
        NetworkManager.getTravelTimeFromGoogle(originLat: startingLat, originLon: startingLon, destinationLat: destinationLat, destinationLon: destinationLon) { travelTime,error in
            guard error == nil else{
                self.displayAlert(title: "Error", message: error?.localizedDescription)
                return
                }
            
            print("\(travelTime)")
            }
    }
    
    
    
    //methods could be refactored to be outside of this class
    
    func startTrip(){
        let tripStartValue = Date()
        saveCoreDataTripDate(tripDate: tripStartValue)
        UserDefaults.standard.set(tripStartValue, forKey: "tripStartValue")
        getTravelTimeFromGoogle()
    }
    
    func endTrip(){
        calculateTimeElapsed()
    }
    
    
    
    func calculateTimeElapsed(){
        var elapsedTime = 0.0
        let tripStartValue = UserDefaults.standard.object(forKey: "tripStartValue") as? Date
        let tripEndValue = Date()
        
        if let tripStartValue = tripStartValue{
             elapsedTime = tripEndValue.timeIntervalSince(tripStartValue)
        }
        saveElapsedTime(elapsedTime: elapsedTime)
    }
    
    
    func saveElapsedTime(elapsedTime: Double){
        let fetchRequest:NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let tripStartValue = UserDefaults.standard.object(forKey: "tripStartValue") as? NSDate
        if let tripStartValue = tripStartValue{
            fetchRequest.predicate = NSPredicate(format: "tripDate = %@", tripStartValue)
        }
        
        let context = CoreDataManager.getContext()
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        if let data = fetchedResultsController.fetchedObjects, data.count > 0 {
            print("found \(data.count) objects")
            if let trip = data.first{ // should only find one match, with the exact start time timestamp, but just in case grab the first one
                print("tripStartDate \(trip.tripDate!)")
                trip.setValue(elapsedTime, forKey: "timeElapsed")
            }
        }
        CoreDataManager.saveContext()
    }
    
    func saveCoreDataTripDate(tripDate: Date){
        let managedContext = CoreDataManager.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: managedContext)!
        let trip = NSManagedObject(entity: entity, insertInto: managedContext)
        
        trip.setValue(tripDate, forKey: "tripDate")
        CoreDataManager.saveContext()
    }
    
    
    //UI TextField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
}
