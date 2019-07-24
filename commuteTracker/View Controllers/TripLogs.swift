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

class TripTableViewCell: UITableViewCell{
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}




class TripLogs: UIViewController, UITabBarDelegate, UITableViewDataSource{

    
    var trips = [Trip]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTrips()
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    func fetchTrips(){
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "tripDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do{
            let results = try CoreDataManager.getContext().fetch(fetchRequest)
            print("found \(results.count) trips")
            if results.count > 0 {
                trips = results
            }
            
        }
        catch{
            print("error getting trip data")
        }
    }
    
    func displayElapsedTime(elapsedTime: Double) -> String{
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        return String("\(minutes) m \(seconds) s")
    }
    
    func displayDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripTableViewCell", for: indexPath) as! TripTableViewCell
        let trip = trips[indexPath.row]
        
        cell.elapsedTimeLabel.text = displayElapsedTime(elapsedTime: trip.timeElapsed)
        
        if let tripDate = trip.tripDate{ // for some reason have to always unwrap date
            cell.dateLabel.text = displayDate(date: tripDate)
        }
        return cell
    }
    
}
