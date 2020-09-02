//
//  CommonCodeDispose.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/19.
//  Copyright © 2020 任前辈. All rights reserved.
//
import Alamofire
import Foundation


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



