//
//  TripDetails.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/24/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import UIKit

class TripDetails: UIViewController{
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var googleEstimateLabel: UILabel!
    @IBOutlet weak var actualTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.barTintColor = UIColor.black
    }
    override func viewDidLoad() {
        loadData()
    }
    
    var selectedTrip: Trip!
    
    
    
    
    @IBAction func pressedBack(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func loadData(){
        if let trip = selectedTrip{
            self.googleEstimateLabel.text = displayElapsedTime(elapsedTime: trip.googleTime)
            self.actualTimeLabel.text = displayElapsedTime(elapsedTime: trip.timeElapsed)
            self.startTimeLabel.text = displayAmpmTime(date: trip.tripDate!)
        }
    }
    
    func displayElapsedTime(elapsedTime: Double) -> String{
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        return String("\(minutes) m \(seconds) s")
    }
    
    func displayAmpmTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    

    
}
