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

class CurrentTrip: UIViewController {
    
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    
    var tripInProgress = false
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        startStopButton.layer.cornerRadius = 10
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
    
    
    
    //methods could be refactored to be outside of this class
    
    func startTrip(){
        let tripStartValue = Date()
        saveCoreDataTripDate(tripDate: tripStartValue)
        UserDefaults.standard.set(tripStartValue, forKey: "tripStartValue")
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
            if let trip = data.first{
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
    

    
}
