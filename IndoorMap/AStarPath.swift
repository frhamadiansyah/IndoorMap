//
//  AStarPath.swift
//  IndoorMap
//
//  Created by Fandrian Rhamadiansyah on 08/07/21.
//  Copyright © 2021 Dent Reality. All rights reserved.
//

import Foundation
import CoreLocation

let divided: Double = 100000

class RoomCoordinate {
    var longitude: Int
    var latitude: Int
    
    var parent: RoomCoordinate?
    
    var g = 0
    var h = 0
    var f = 0
    
    init(longitude: Int, latitude: Int) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

class RoomArea {
    let roomCoordinates: [RoomCoordinate]
    let minLongitude: Int?
    let maxLongitude: Int?
    let minLatitude: Int?
    let maxLatitude: Int?
    
    init(roomCoordinates: [RoomCoordinate]) {
        self.roomCoordinates = roomCoordinates
        
        let longitudeArray = roomCoordinates.map(\.longitude)
        let latitudeArray = roomCoordinates.map(\.latitude)
        
        let minLongitude = longitudeArray.min()
        let maxLongitude = longitudeArray.max()
        let minLatitude = latitudeArray.min()
        let maxLatitude = latitudeArray.max()
        
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
    }
}

class AStarPath {
    
    var origin: RoomCoordinate
    var destination: RoomCoordinate
    var hallway: [RoomCoordinate]

    //object initialization
    init(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, hallway: [CLLocationCoordinate2D]){
        
        self.hallway = AStarPath.createGrid(area: hallway)
        self.origin = AStarPath.createNode(coordinate: origin)
        self.destination = AStarPath.createNode(coordinate: destination)
        
    }
    
    static func createGrid(area: [CLLocationCoordinate2D]) -> [RoomCoordinate] {
        var roomCoordinates = [RoomCoordinate]()
        for coordinate in area {
            roomCoordinates.append(AStarPath.createNode(coordinate: coordinate))
        }
        
        return roomCoordinates
    }
    
    static func createNode(coordinate: CLLocationCoordinate2D) -> RoomCoordinate {
        let lat = Int(coordinate.latitude.magnitude * divided)
        let lon = Int(coordinate.longitude.magnitude * divided)
        
        return RoomCoordinate(longitude: lon, latitude: lat)
    }
    
    static func returnToCoordinate(roomCoordinates: [RoomCoordinate]) -> [CLLocationCoordinate2D] {
        var result = [CLLocationCoordinate2D]()
        
        for room in roomCoordinates {
            let lat: Float = Float(room.latitude) / Float(divided)
            let lon: Float = Float(room.longitude) / Float(divided)
            
            result.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
        }
        
        return result
    }
    
    
}

extension AStarPath {
    func AStar() -> [RoomCoordinate] {
        
        var open_list = [RoomCoordinate]()
        var closed_list = [RoomCoordinate]()
        
        let hallwayArea = RoomArea(roomCoordinates: hallway)
        
        open_list.append(origin)
        
        while open_list.count > 0 {
            var current_node = open_list[0]
            var current_index = 0
            
            for (index, item) in open_list.enumerated() {
                if item.f < current_node.f {
                    current_node = item
                    current_index = index
                }
            }
            open_list.remove(at: current_index)
            closed_list.append(current_node)
            
            if (current_node.longitude == destination.longitude) && (current_node.latitude == destination.latitude) {
                var path = [RoomCoordinate]()
                var current = current_node
                
                while (current.parent != nil) {
                    path.append(current)
                    
                    current = current.parent!
                }
//                while current.:
//                    path.append(current.position)
//                    current = current.parent
//                return path[::-1] # Return reversed path
                return path.reversed()
            }
            
            var children = [RoomCoordinate]()
//            for new_position in [[0, -1], [0, 1], [-1, 0], [1, 0], [-1, -1], [-1, 1], [1, -1], [1, 1]] {
            for new_position in [[0, -1], [0, 1], [-1, 0], [1, 0]] { // no diagonal path
                
                let nodePosition = [current_node.longitude + new_position[0], current_node.latitude + new_position[1]]
                
                if (nodePosition[0] < hallwayArea.minLongitude!) ||
                    (nodePosition[0] > hallwayArea.maxLongitude!) ||
                    (nodePosition[1] < hallwayArea.minLatitude!) ||
                    (nodePosition[1] > hallwayArea.maxLatitude!){
                    continue
                }
                
                children.append(RoomCoordinate(longitude: nodePosition[0], latitude: nodePosition[1]))
            }
            
            for child in children {
                
                for closed_child in closed_list {
                    if (child.longitude == closed_child.longitude) && (child.latitude == closed_child.latitude) {
                        continue
                    }
                }
                
                child.g = current_node.g + 1
                child.h = ((child.longitude - destination.longitude) ^ 2) + ((child.latitude - destination.latitude) ^ 2)
                child.f = child.g + child.h
                
                for open_child in open_list {
                    if (child.longitude == open_child.longitude) && (child.latitude == open_child.latitude) && (child.g > open_child.g){
                        continue
                    }
                }

                open_list.append(child)
                print(open_list.count)
            }



        }
        
        return open_list
    
        
    }
}
