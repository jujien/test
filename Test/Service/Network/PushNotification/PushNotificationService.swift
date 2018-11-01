//
//  PushNotificationService.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift
import CoreLocation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    fileprivate let center: UNUserNotificationCenter
    let permission: Observable<Bool>
    
    fileprivate init() {
        self.center = .current()
        self.permission = Observable<UNUserNotificationCenter>
            .just(self.center)
            .flatMap({ (center) -> Observable<Bool> in
                return Observable<Bool>.create({ (observer) -> Disposable in
                    center.requestAuthorization(options: [.alert, .sound], completionHandler: { (status, error) in
                        observer.onNext(status)
                    })
                    return Disposables.create()
                })
            })
    }
    
    func request(title: String, subTitle: String, body: String, region: CLRegion) -> Observable<()> {
        return Observable<UNUserNotificationCenter>
            .just(self.center)
            .flatMap({ (center) -> Observable<()> in
                return Observable<()>.create({ (observer) -> Disposable in
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.subtitle = subTitle
                    content.body = body
                    content.sound = UNNotificationSound.default
                    region.notifyOnEntry = true
                    region.notifyOnExit = false 
                    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                    let request = UNNotificationRequest(identifier: String.random(8), content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(())
                        }
                    })
                    return Disposables.create()
                })
            })
    }
}

extension String {
    static func random(_ n: Int) -> String {
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var s = ""
        
        for _ in 0..<n
        {
            let r = Int.random(in: 0..<a.count)
            
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        
        return s
    }
}
