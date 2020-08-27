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
    var headers: HTTPHeaders?
    var requestModifier: ((inout URLRequest) throws -> Void)?

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: url, method: method, headers: headers)
        try requestModifier?(&request)
        
        return try encoding.encode(request, with: parameters)
    }
    
    
}

