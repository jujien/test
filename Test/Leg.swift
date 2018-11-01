//
//  Leg.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

struct Leg {
    var distance: Double = 0.0
    var duration: Double = 0.0
    var startAddress: String = ""
    var endAddress: String = ""
    var startLocation: CLLocationCoordinate2D = .init()
    var endLocation: CLLocationCoordinate2D = .init()
    var steps: [Step] = []
}

extension Leg {
    static func map(json: JSON) -> Leg {
        var leg = Leg()
        leg.distance = json["distance"]["value"].double ?? 0.0
        leg.duration = json["duration"]["value"].double ?? 0.0
        leg.startAddress = json["start_address"].string ?? ""
        leg.startLocation = .init(latitude: json["start_location"]["lat"].double ?? 0.0, longitude: json["start_location"]["lng"].double ?? 0.0)
        leg.endAddress = json["end_address"].string ?? ""
        leg.endLocation = .init(latitude: json["end_location"]["lat"].double ?? 0.0, longitude: json["end_location"]["lng"].double ?? 0.0)
        leg.steps = json["steps"].array?.map { Step.map(json: $0) } ?? []
        return leg
    }
}
