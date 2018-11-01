//
//  Dispatcher.swift
//  Test
//
//  Created by Vũ Kiên on 31/10/2018.
//  Copyright © 2018 Kien Vu. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol Dispatcher {
    var host: String { get }
 
    func fetch<Rq: APIRequest, Rp: APIResponse>(request: Rq, handler: Rp) -> Observable<Rp.Resource>
}

extension Dispatcher {
    func fetch<Rq, Rp>(request: Rq, handler: Rp) -> Observable<Rp.Resource> where Rq : APIRequest, Rp : APIResponse {
        return request
            .request(dispatcher: self)
            .flatMap({ (dataRequest) -> Observable<Rp.Resource> in
                return Observable<Rp.Resource>
                    .create({ (observer) -> Disposable in
                        (dataRequest as? DataRequest)?
                            .responseJSON(completionHandler: { (response) in
                                print(response.response?.url?.absoluteString as Any)
                                switch response.result {
                                case .success(_):
                                    if let result = handler.map(data: response.data, statusCode: response.response?.statusCode ?? 400) {
                                        observer.onNext(result)
                                    } else if let error = handler.error(data: response.data, statusCode: response.response?.statusCode ?? 400, url: response.response?.url?.absoluteString ?? "") {
                                        observer.onError(error)
                                    }
                                    break
                                case .failure(let error):
                                    observer.onError(
                                        NetworkError(
                                            domain: response.response?.url?.absoluteString ?? "",
                                            statusCode: response.response?.statusCode ?? 400,
                                            userInfo: ["message": error.localizedDescription]
                                        )
                                    )
                                    break
                                }
                            })
                        return Disposables.create {
                            dataRequest.cancel()
                        }
                    })
            })
    }
}
