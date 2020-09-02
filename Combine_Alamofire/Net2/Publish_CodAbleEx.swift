//
//  Publish_CodAbleEx.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/9/2.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Combine
import Foundation

//MARK:通用错误map协议
protocol NetCodeMap {
    associatedtype Value
    func mapCode(url:String?) -> Result<Value, HYNetError>
    var _hy_Net_code:Int {get}
    var _success_value:Value {get}
}

extension NetCodeMap {
   
    func mapCode(url: String?) -> Result<Value, HYNetError> {
           if _hy_Net_code == 200 {
            return .success(_success_value)
           }else {
               if url?.hasPrefix("特定地址") ?? false {
                   return .failure(HYNetError.ResultError("特定地址 code\(_hy_Net_code) 不对"))
               }else{
                   return .failure(HYNetError.ResultError(" code\(_hy_Net_code) 不对"))
               }
           }
    }
}


//MARK:Codable 通用层类型
class NetPublishCommonCodableResult<T:Codable>:Codable,NetCodeMap {
    var _hy_Net_code: Int {
        return code
    }
    
    var _success_value: T? {
        return data
    }
    
    typealias Value = T?

    var code:Int = 0
    var msg:String = ""
    var data:T?

   
    
}





//MARK:Publisher 扩展

extension AnyPublisher {
    
    func mapCodable<T:Codable>() -> AnyPublisher<Result<T,HYNetError>,Never>  where Failure == Never,Output == Result<Data,HYNetError>{
       
        map { (result) -> Result<T,HYNetError> in
         
            return  result.flatMap { (data) -> Result<T, HYNetError> in
               
                let decode = JSONDecoder.init()
                do {
                    let value = try decode.decode(T.self, from: data)
                    return .success(value)
                } catch  {
                    return .failure(HYNetError.decode(.failed(request:"",data:data,error:error)))
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    
    func mapValueCodable<T:Codable>(url:String? = nil) -> AnyPublisher<Result<T?,HYNetError>,Never> where Failure == Never,Output == Result<Data,HYNetError> {
        
        map { (result) -> Result<T?,HYNetError> in
         
            return  result.flatMap { (data) -> Result<T?, HYNetError> in
               
                let decode = JSONDecoder.init()
                do {
                    let commonValue = try decode.decode(NetPublishCommonCodableResult<T>.self, from: data)
                    switch commonValue.mapCode(url: url) {
                        case let .success(v):
                            return.success(v)
                        case let .failure(error):
                            return .failure(error)
                     }
                } catch  {
                    return .failure(HYNetError.decode(.failed(request:"",data:data,error:error)))
                }
            }
            
        }.eraseToAnyPublisher()
        
    }
}
