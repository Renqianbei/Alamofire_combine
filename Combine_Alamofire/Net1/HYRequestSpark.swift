//
//  HyRequestSoul.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/26.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import Alamofire
import Combine

struct HYRequestSpark:URLRequestConvertible {
   
    let url: URLConvertible
    var method: HTTPMethod = .get
    var parameters: Parameters?
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: [String: String] = [:]
    var requestModifier: ((inout URLRequest) throws -> Void)?

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: map(url: url), method: method, headers: map(headers: headers))
        try requestModifier?(&request)
        
        return try encoding.encode(request, with: parameters.map(map(parameters:)))
    }
    
}

extension HYRequestSpark {
    
    func fire() -> AnyPublisher<Result<HYRequest.Response,HYNetError>,Never> {
        return HYRequest.shared.requestPublish(requestConvert: self)
    }
    
    func dataRequest() -> DataRequest {
        return HYRequest.shared.request(self)
    }
    
}

extension DataRequest {
    
    func spark() -> AnyPublisher<Result<HYRequest.Response,HYNetError>,Never> {
        return HYRequest.shared.requestPublish(request: self)
    }
}




protocol  HYNetParasMap {
    
    func map(parameters:Parameters) -> Parameters
    func map(headers:[String:String]) -> HTTPHeaders
    func map(url:URLConvertible) -> URLConvertible
}


extension HYRequestSpark:HYNetParasMap {
    
    func map(parameters:Parameters) -> Parameters {
        //todo:
        return parameters
    }
    func map(headers:[String:String]) -> HTTPHeaders {
        //todo:
        return HTTPHeaders.init(headers)
    }
    
    func map(url:URLConvertible) -> URLConvertible {
        //todo:
        return url
    }
}


