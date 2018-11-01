//
//  TestDispatcher.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation

struct TestDispatcher: Dispatcher {
    var host: String {
        return "https://mhealth-api.herokuapp.com"
    }
}
