//
//  HyRequestSoul.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/26.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import Alamofire




struct HyRequestSoul:URLRequestConvertible {
   
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

protocol  HYNetParasMap {
    
    func map(parameters:Parameters) -> Parameters
    func map(headers:[String:String]) -> HTTPHeaders
    func map(url:URLConvertible) -> URLConvertible
}


extension HyRequestSoul:HYNetParasMap {
    
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


