//
//  TripTracker.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/25/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class TripTracker{
    
    static let sharedInstance = TripTracker()
    
     private init(){}
    
    func getTravelTimeFromGoogle(){
        var startingLat = 0.0
        var startingLon = 0.0
        var destinationLat = 0.0
        var destinationLon = 0.0
        
        if isMorningTrip(){
            startingLat = UserDefaults.standard.double(forKey: "startingLatitude")
            startingLon = UserDefaults.standard.double(forKey: "startingLongitude")
            destinationLat = UserDefaults.standard.double(forKey: "destinationLatitude")
            destinationLon = UserDefaults.standard.double(forKey: "destinationLongitude")
        }
        else {
            startingLat = UserDefaults.standard.double(forKey: "destinationLatitude")
            startingLon = UserDefaults.standard.double(forKey: "destinationLongitude")
            destinationLat = UserDefaults.standard.double(forKey: "startingLatitude")
            destinationLon = UserDefaults.standard.double(forKey: "startingLongitude")
        }
        
        NetworkManager.getTravelTimeFromGoogle(originLat: startingLat, originLon: startingLon, destinationLat: destinationLat, destinationLon: destinationLon) { travelTime,error in
            guard error == nil else{
                print("Error \(String(describing: error?.localizedDescription))")
                return
            }
            self.saveGoogleRouteTime(googleTime: travelTime)
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
        let fetchedResultsController = CoreDataManager.getFetchedControllerByDate()
        
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
    
    func saveGoogleRouteTime(googleTime: Int){
        let fetchedResultsController = CoreDataManager.getFetchedControllerByDate()
        
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
                trip.setValue(googleTime, forKey: "googleTime")
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
    
    
    func isMorningTrip() -> Bool{
        let calendar = Calendar.current
        let now = Date()
        let fourThirtyAM = calendar.date(
            bySettingHour: 4,
            minute: 30,
            second: 0,
            of: now)!
        
        let elevenThirtyAM = calendar.date(
            bySettingHour: 11,
            minute: 30,
            second: 0,
            of: now)!
        
        if now >= fourThirtyAM &&
            now <= elevenThirtyAM
        {
            return true
        }
        
        return false
    }
    
    
    
}
