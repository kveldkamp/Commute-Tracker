//
//  tripLogs.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/23/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TripLogs: UIViewController {
    
var elapsedTime = 0
    
    
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTrips()
    }
    
    
    
    func fetchTrips(){
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        
        do{
            let results = try CoreDataManager.getContext().fetch(fetchRequest)
            print("found \(results.count) pins")
            if results.count > 0 {
                displayElapsedTime(elapsedTime: results.first!.timeElapsed)
            }
            
        }
        catch{
            print("error getting trip data")
        }
    }
    
    
    func displayElapsedTime(elapsedTime: Double){
        let elapsedTime = UserDefaults.standard.integer(forKey: "elapsedTime")
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        elapsedTimeLabel.text = String("\(minutes) minutes \(seconds) seconds")
    }
    
}
