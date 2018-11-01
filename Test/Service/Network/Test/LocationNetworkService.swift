//
//  LocationNetworkService.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON
import CoreLocation

struct LocationRequest: APIRequest {
    var path: String {
        return "/location/all"
    }
}

struct LocationResponse: APIResponse {
    typealias Resource = [CLLocationCoordinate2D]
    
    func map(data: Data?, statusCode: Int) -> [CLLocationCoordinate2D]? {
        guard let json = self.json(data: data), statusCode >= 200 && statusCode < 400 else { return nil }
        return json.array?
            .map { CLLocationCoordinate2D(latitude: $0["latitude"].double ?? 0.0, longitude: $0["longitude"].double ?? 0.0) }
    }
    
    func error(data: Data?, statusCode: Int, url: String) -> Error? {
        return nil
    }
}

struct LocationNetworkService: NetworkService {
    static let shared = LocationNetworkService()
    
    var dispatcher: Dispatcher = TestDispatcher()
    
    fileprivate init() {}
    
    func findAll() -> Observable<[CLLocationCoordinate2D]> {
        return self.dispatcher.fetch(request: LocationRequest(), handler: LocationResponse())
    }
}
