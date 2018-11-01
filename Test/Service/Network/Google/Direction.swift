//
//  Direction.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import RxSwift

class DirectionRequest: APIRequest {
    
    var path: String {
        return "/maps/api/directions/json"
    }
    
    var parameters: Parameters? {
        var params = [
            "origin": "\(self.origin.latitude),\(self.origin.longitude)",
            "destination": "\(self.destination.latitude),\(self.destination.longitude)",
            "key": "AIzaSyBukDRZk_mLbnqDY0jYHhQYxoWeYofYgZ0",
        ]
        if !self.waypoints.isEmpty {
            var waypoints = self.waypoints.map { "\($0.latitude),\($0.longitude)" }
            waypoints.insert("optimize:true", at: 0)
            params["waypoints"] = waypoints.joined(separator: "|")
        }
        return params
    }
    
    fileprivate let origin: CLLocationCoordinate2D
    fileprivate let destination: CLLocationCoordinate2D
    fileprivate let waypoints: [CLLocationCoordinate2D]
    
    init(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D]) {
        self.origin = origin
        self.destination = destination
        self.waypoints = waypoints
    }
}

class DirectionResponse: APIResponse {
    typealias Resource = [Leg]
    
    func map(data: Data?, statusCode: Int) -> [Leg]? {
        guard let json = self.json(data: data), statusCode >= 200 && statusCode < 400 else { return nil }
        return json["routes"]
            .array?
            .map { $0["legs"].array?.map { Leg.map(json: $0) } ?? [] }
            .first
    }
    
    func error(data: Data?, statusCode: Int, url: String) -> Error? {
        guard let json = self.json(data: data), statusCode >= 400 else { return nil }
        return NetworkError(domain: url, statusCode: statusCode, userInfo: ["message": json["error_message"].string ?? ""])
    }
}

class GoogleDirectionService: NetworkService {
    static let shared = GoogleDirectionService()
    
    fileprivate init() {}
    
    var dispatcher: Dispatcher = GoogleDispatcher()
    
    func direction(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D]) -> Observable<[Leg]> {
        return self.dispatcher
            .fetch(request: DirectionRequest.init(origin: origin, destination: destination, waypoints: waypoints), handler: DirectionResponse())
    }
}
