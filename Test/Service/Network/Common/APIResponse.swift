//
//  APIResponse.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct NetworkError: Error {
    var domain: String = ""
    var statusCode: Int = 400
    var userInfo: [String: Any]? = nil
    
    init(domain: String = "", statusCode: Int = 400, userInfo: [String: Any]? = nil) {
        self.domain = domain
        self.statusCode = statusCode
        self.userInfo = userInfo
    }
}

protocol APIResponse {
    associatedtype Resource
    
    func map(data: Data?, statusCode: Int) -> Resource?
    
    func error(data: Data?, statusCode: Int, url: String) -> Error?
}


extension APIResponse {
    func json(data: Data?) -> JSON? {
        guard let data = data else { return nil }
        return try? JSON(data: data)
    }
}
