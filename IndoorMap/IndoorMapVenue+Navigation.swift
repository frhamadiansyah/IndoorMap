//
//  IndoorMapVenue+Extensions.swift
//  IndoorMap
//
//  Created by Andrew Hart on 13/10/2019.
//  Copyright © 2019 Dent Reality. All rights reserved.
//

import Foundation
import CoreLocation

extension IndoorMapVenue {
	func findRoute(from: IndoorMapUnit, to: IndoorMapUnit) -> [CLLocationCoordinate2D] {
        let dummy = [
        CLLocationCoordinate2D(latitude: 51.52478927942754, longitude: -0.04055524521390908),
        CLLocationCoordinate2D(latitude: 51.52473122482326, longitude: -0.04046850954182447)
        ]
        
        
        guard let origin = openings.filter{ $0.origin?.id == from.id }.first else { return dummy.dropLast()}

        guard let destination = openings.filter{ $0.origin?.id == to.id }.first else {return dummy}
        
        guard let hallway = units.filter{ $0.category == .hallway }.first  else { return dummy }
        
        let location = [origin.coordinate, destination.coordinate]
        
        let aStarPathFinder = AStarPath(origin: origin.coordinate, destination: destination.coordinate, hallway: hallway.coordinates)
        
        let pathCoordinate = AStarPath.returnToCoordinate(roomCoordinates: aStarPathFinder.AStar())

        return location
	}
}


