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
            startStopButton.setTitle("Start Commute", for: .normal)
            tripInProgress = false
            let tripEndValue = Date()
            UserDefaults.standard.set(tripEndValue, forKey: "tripEndValue")
            calculateTimeElapsed()
        }
        else if !tripInProgress{ //start trip
            startStopButton.setTitle("Finish Commute", for: .normal)
            tripInProgress = true
            let tripStartValue = Date()
            UserDefaults.standard.set(tripStartValue, forKey: "tripStartValue")
        }
    }
    
    func calculateTimeElapsed(){
        var elapsedTime = 0.0
        let tripStartValue = UserDefaults.standard.object(forKey: "tripStartValue") as? Date
        let tripEndValue = UserDefaults.standard.object(forKey: "tripEndValue") as? Date
        
        if let tripStartValue = tripStartValue, let tripEndValue = tripEndValue{
             elapsedTime = tripEndValue.timeIntervalSince(tripStartValue)
        }
        
        saveElapsedTime(elapsedTime: elapsedTime)
        UserDefaults.standard.set(elapsedTime, forKey: "elapsedTime")
    }
    
    
    func saveElapsedTime(elapsedTime: Double){
        let managedContext = CoreDataManager.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: managedContext)!
        let trip = NSManagedObject(entity: entity, insertInto: managedContext)
        
        trip.setValue(elapsedTime, forKey: "timeElapsed")
        CoreDataManager.saveContext()
    }
    

    
}
