//
//  LocationService.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class LocationService: NSObject {
    
    static let `default` = LocationService()
    
    fileprivate let manager: CLLocationManager
    fileprivate let coordinateSubject = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D())
    fileprivate var lastLocation: CLLocation!
    fileprivate let disposeBag = DisposeBag()
    
    let permission: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: true)
    let location: Observable<CLLocationCoordinate2D>
    
    fileprivate override init() {
        self.manager = .init()
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.manager.distanceFilter = 100.0
        self.location = self.coordinateSubject.asObservable().filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
        super.init()
        self.config()
        self.event()
    }
    
    fileprivate func config() {
        self.manager.delegate = self
    }
    
    fileprivate func event() {
        self.permission
            .subscribe(onNext: { [weak self] (status) in
                if status {
                    self?.startUpdate()
                } else {
                    self?.manager.stopUpdatingLocation()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func startUpdate() {
        self.manager.startMonitoringVisits()
        self.manager.startMonitoringSignificantLocationChanges()
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        if location.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if location.horizontalAccuracy < 0 {
            return
        }
        if self.lastLocation == nil || self.lastLocation.horizontalAccuracy > location.horizontalAccuracy {
            self.lastLocation = location
            if self.lastLocation.horizontalAccuracy <= self.manager.desiredAccuracy {
                self.coordinateSubject.onNext(self.lastLocation.coordinate)
            } else {
                self.coordinateSubject.onNext(location.coordinate)
            }
        } else {
            self.coordinateSubject.onNext(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.coordinateSubject.onError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            self.permission.onNext(false)
            break
        case .restricted:
            self.permission.onNext(false)
            break
        default:
            self.permission.onNext(true)
            break
        }
    }
}
