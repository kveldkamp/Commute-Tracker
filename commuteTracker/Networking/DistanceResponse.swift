//
//  DistanceResponse.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/24/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation

struct DistanceResponse: Codable{
    let rows: [elements]
    let status: String
}

struct elements: Codable {
    let elements: [elementObjects]
}

struct elementObjects: Codable{
    let distance: distanceObject
    let duration: durationObject
    let status: String
}

struct distanceObject: Codable{
    let text: String
    let value: Int
}

struct durationObject: Codable{
    let text: String
    let value: Int
}
