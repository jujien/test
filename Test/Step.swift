//
//  Step.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

struct Step {
    var distance: Double = 0.0
    
    var duration: TimeInterval = 0.0
    
    var startLocation: CLLocationCoordinate2D = .init()
    
    var endLocation: CLLocationCoordinate2D = .init()
    
    var polyline: String = ""
}

extension Step {
    static func map(json: JSON) -> Step {
        var step = Step()
        step.distance = json["distance"]["value"].double ?? 0.0
        step.duration = json["duration"]["value"].double ?? 0.0
        step.startLocation = .init(latitude: json["start_location"]["lat"].double ?? 0.0, longitude: json["start_location"]["lng"].double ?? 0.0)
        step.endLocation = .init(latitude: json["end_location"]["lat"].double ?? 0.0, longitude: json["end_location"]["lng"].double ?? 0.0)
        step.polyline = json["polyline"]["points"].string ?? ""
        return step
    }
}
