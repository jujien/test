//
//  APIRequest.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol APIRequest {
    var path: String { get }
    
    var method: HTTPMethod { get }
    
    var parameters: Parameters? { get }
    
    var headers: HTTPHeaders? { get }
    
    var encoding: ParameterEncoding { get }
    
    func request(dispatcher: Dispatcher) -> Observable<Request> 
}

extension APIRequest {
    var method: HTTPMethod { return .get }
    
    var parameters: Parameters? { return nil }
    
    var headers: HTTPHeaders? { return nil }
    
    var encoding: ParameterEncoding { return URLEncoding.default }
    
    func request(dispatcher: Dispatcher) -> Observable<Request> {
        return Observable<Request>
            .just(
                Alamofire.request(dispatcher.host + self.path, method: self.method, parameters: self.parameters, encoding: self.encoding, headers: self.headers)
            )
    }
}
