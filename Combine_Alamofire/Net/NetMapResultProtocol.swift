//
//  CommonCodeDispose.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/19.
//  Copyright © 2020 任前辈. All rights reserved.
//
import Alamofire
import Foundation

enum HYNetError:Error {
    
    case AFError(AFError)
    case ResultError(String)
    
    enum DecodeError:Error {
        case emptyData(request: String?)
        case failed(request: String?,data: Data,error:Error)
        
        var localizedDescription: String {
            switch self {
            case let .emptyData(request):
                return " request:\(request ?? "") ||| data: 结果为空"
            case let .failed(request,_,error):
                return "request:\(request ?? "")||| error:\(error.localizedDescription)"
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



//MARK:网络结果处理层协议
protocol HyCodeExplain {
    associatedtype Value
    var result:Result<Value, HYNetError> { get }
}



//MARK:解析协议
protocol HyDecodeSerializer {
   static func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?) throws -> Self
}




//MARK:Alamofire 解析协议
class HYNetSerializer<T:HyDecodeSerializer>:ResponseSerializer {
    
        
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        if let _error = error {
            throw _error
        }else{
           return try T.serialize(request: request, response: response, data: data)
        }
        
    }
    
    
}



