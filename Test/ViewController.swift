//
//  ViewController.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import UIKit
import GoogleMaps
import RxCocoa
import RxSwift
import GooglePlaces

class ViewController: UIViewController {
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var detailLabel: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let legs: BehaviorSubject<[Leg]> = .init(value: [])
    fileprivate let list: BehaviorSubject<[CLLocationCoordinate2D]> = .init(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getListLocation()
        self.setupUI()
        self.event()
    }
    
    // MARK: - Data
    fileprivate func getListLocation() {
        LocationNetworkService
            .shared
            .findAll()
            .subscribe(self.list)
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func findFarthestLocation() -> Observable<CLLocationCoordinate2D> {
        return Observable<(CLLocationCoordinate2D, [CLLocationCoordinate2D])>
            .combineLatest(LocationService.default.location, self.list, resultSelector: { ($0, $1) })
            .flatMap { (current, list) -> Observable<CLLocationCoordinate2D> in
                let distances: [Double] = list.map { GMSGeometryDistance(current, $0) }
                if let index = distances.lastIndex(where: {$0 == distances.max() ?? 0.0 }) {
                    return Observable<CLLocationCoordinate2D>.just(list[index])
                }
                return Observable.empty()
        }
    }
    
    fileprivate func directionService() -> Observable<[Leg]> {
        return Observable<(CLLocationCoordinate2D, CLLocationCoordinate2D, [CLLocationCoordinate2D])>
            .combineLatest(
                LocationService.default.location,
                self.findFarthestLocation(),
                self.list.filter { !$0.isEmpty },
                resultSelector: { ($0, $1, $2) }
            )
            .flatMap {
                GoogleDirectionService.shared
                    .direction(origin: $0, destination: $1, waypoints: $2)
                    .catchError { (error) -> Observable<[Leg]> in
                        return Observable.empty()
                }
            }
    }
    
    // MARK: - UI
    fileprivate func setupUI() {
        self.setupGoogleMapView()
        self.setupMarker()
        self.drawLine()
        self.setupDetailLabel()
    }
    
    fileprivate func setupGoogleMapView() {
        LocationService.default
            .location
            .map { GMSCameraPosition.camera(withTarget: $0, zoom: 12.0) }
            .subscribe(onNext: { [weak self] (camera) in
                self?.mapView.camera = camera
            })
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func setupMarker() {
        LocationService.default
            .location
            .map { GMSMarker(position: $0) }
            .subscribe(onNext: { [weak self] (marker) in
                marker.map = self?.mapView
            })
            .disposed(by: self.disposeBag)
        
        self.list
            .subscribe(onNext: { [weak self] (list) in
                list.forEach({ (location) in
                    let marker = GMSMarker(position: location)
                    marker.icon = #imageLiteral(resourceName: "icons8-marker-50")
                    marker.map = self?.mapView
                })
            })
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func drawLine() {
        self.legs
            .subscribe(onNext: { (legs) in
                legs
                    .map { $0.steps }
                    .forEach({ (steps) in
                        steps
                            .map { GMSPath.init(fromEncodedPath: $0.polyline) }
                            .forEach({ [weak self] (path) in
                                let polyline = GMSPolyline(path: path)
                                polyline.strokeWidth = 4.0
                                polyline.strokeColor = UIColor.red
                                polyline.map = self?.mapView
                            })
                    })
            })
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func setupDetailLabel() {
        self.legs
            .map { (legs) -> Double in
                return legs.reduce(0.0, { $0 + $1.distance })
            }
            .map { String.init(format: "Distance: %.2f km", $0 / 1000.0) }
            .subscribe(self.detailLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Event
    fileprivate func event() {
        PushNotificationService.shared.permission.subscribe().disposed(by: self.disposeBag)
        self.directionButtonEvent()
        self.pushNotificationEvent()
//        Observable<(CLLocationCoordinate2D, [CLLocationCoordinate2D])>
//            .combineLatest(LocationService.default.location, self.list, resultSelector: {($0, $1)})
//            .map { (current, list) -> [CLLocationCoordinate2D] in
//                var array = list
//                array.removeAll(where: {$0.latitude.isEqual(to: current.latitude) && $0.longitude.isEqual(to: current.longitude) })
//                return array
//            }
//            .subscribe(self.list)
//            .disposed(by: self.disposeBag)
    }
    
    fileprivate func directionButtonEvent() {
        self.directionButton
            .rx
            .tap
            .asObservable()
            .withLatestFrom(self.directionService())
            .subscribe(self.legs)
            .disposed(by: self.disposeBag)
    }
    
    fileprivate func pushNotificationEvent() {
        self.list
            .map { (list) -> [CLRegion] in
                return list.map { CLCircularRegion(center: $0, radius: 100.0, identifier: String.random(8)) }
            }
            .flatMap { (regions) -> Observable<()> in
                return Observable<CLRegion>
                    .from(regions)
                    .flatMap {
                        PushNotificationService.shared
                            .request(title: "Test", subTitle: "Near", body: "", region: $0)
                            .catchError({ (error) -> Observable<()> in
                                print(error.localizedDescription)
                                return Observable.empty()
                            })
                }
            }
            .subscribe()
            .disposed(by: self.disposeBag)
    }

}

