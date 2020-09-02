//
//  HYNetError.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/27.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Alamofire
import Foundation

enum HYNetError:Error {
    
    case AFError(AFError)
    case ResultError(String)
    
    enum DecodeError:Error {
        case emptyData(response:HYRequest.Response?)
        case failed(response:HYRequest.Response?,error:Error)
        
        var localizedDescription: String {
            switch self {
            case let .emptyData(response):
                return " request:\(response?.response?.url?.absoluteString ?? "") ||| data: 结果为空"
            case let .failed(response,error):
                return "request:\(response?.response?.url?.absoluteString ?? "")||| error:\(error.localizedDescription)"
            }
        }
    }
    
    case decode(DecodeError)
    
    var localizedDescription: String {
        switch self {
        case let .AFError( value):
            return value.localizedDescription
        case let .ResultError( value):
            return value
        case let .decode(value):
            return value.localizedDescription
        }
    }
    
    
    init(afError:AFError) {
        if let error = afError.underlyingError as? HYNetError{
            self = error
        }else{
            self = .AFError(afError)
        }
    }
}
