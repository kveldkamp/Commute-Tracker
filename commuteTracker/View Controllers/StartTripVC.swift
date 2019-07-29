//
//  startTripVC.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/25/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import UIKit

class StartTripVC: UIViewController {
    
    
    @IBOutlet weak var startingLocationLabel: UILabel!
    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startStopButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @IBAction func startStopButtonAction(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "tripInProgress"){ // finish trip
            DispatchQueue.main.async{
                self.startStopButton.setTitle("Start Commute", for: .normal)
            }
            UserDefaults.standard.set(false, forKey: "tripInProgress")
            TripTracker.sharedInstance.endTrip()
        }
        else if !UserDefaults.standard.bool(forKey: "tripInProgress"){ //start trip
            DispatchQueue.main.async{
                self.startStopButton.setTitle("Finish Commute", for: .normal)
            }
            UserDefaults.standard.set(true, forKey: "tripInProgress")
            TripTracker.sharedInstance.startTrip()
        }
    }
    
    
    func loadUI(){
        // add time based functionality
        
        if TripTracker.sharedInstance.isMorningTrip(){
            startingLocationLabel.text = UserDefaults.standard.string(forKey: "startingAddressString")
            destinationLocationLabel.text = UserDefaults.standard.string(forKey: "destinationAddressString")
        }
        else{
            startingLocationLabel.text = UserDefaults.standard.string(forKey: "destinationAddressString")
            destinationLocationLabel.text = UserDefaults.standard.string(forKey: "startingAddressString")
        }
        
        if UserDefaults.standard.bool(forKey: "tripInProgress"){
            startStopButton.setTitle("Finish Commute", for: .normal)
        }
        else if !UserDefaults.standard.bool(forKey: "tripInProgress"){
            startStopButton.setTitle("Start Commute", for: .normal)
        }
        
    }
    
    
}
