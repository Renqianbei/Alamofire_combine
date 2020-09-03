//
//  Publish_CodAbleEx.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/9/2.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Combine
import Foundation

//MARK:通用错误code,map协议
protocol NetCodeMap {
    associatedtype Value
    func mapResult(url:String?) -> Result<Value, HYNetError>
    var _hy_Net_code:Int {get}
    var _hy_Net_value:Value {get}
    var _hy_Net_msg:String {get}
}

extension NetCodeMap {
   
    func mapResult(url: String?) -> Result<Value, HYNetError> {
           if _hy_Net_code == 200 {
            return .success(_hy_Net_value)
           }else {
            //通用code错误处理
               if url?.hasPrefix("特定地址") ?? false {
                   return .failure(HYNetError.ServerResultError(code: _hy_Net_code, msg: _hy_Net_msg, mapMsg: "特定地址 code\(_hy_Net_code) 不对"))
               }else{
                   return .failure(HYNetError.ServerResultError(code: _hy_Net_code, msg: _hy_Net_msg, mapMsg: " code\(_hy_Net_code) 不对"))
               }
           }
    }
    
    
    
    func map<T:Error>(url:String?, mapCommonResult:(_ code:Int,_ value:Value,_ result:Result<Value,HYNetError>)->Result<Value,T>) -> Result<Value,T> {
       
        mapCommonResult(_hy_Net_code,_hy_Net_value,mapResult(url: url))
       
    }
    
    
}


//MARK:Codable 通用层类型
class NetPublishCommonCodableResult<T:Codable>:Codable,NetCodeMap {
    var _hy_Net_code: Int {
        return code
    }
    
    var _hy_Net_value: T? {
        return data
    }
    var _hy_Net_msg:String {
        return msg
    }

    
    typealias Value = T?

    var code:Int = 0
    var msg:String = ""
    var data:T?

   
    
}





//MARK:Publisher 扩展

extension AnyPublisher  where Failure == Never,Output == Result<HYRequest.Response,HYNetError> {
    
    func mapCodable<T:Codable>() -> AnyPublisher<Result<T,HYNetError>,Never> {
       
        map { (result) -> Result<T,HYNetError> in
         
            return  result.flatMap { (response) -> Result<T, HYNetError> in
                
                response.data.map {
                    let decode = JSONDecoder.init()
                    do {
                        let value = try decode.decode(T.self, from: $0)
                        return .success(value)
                    } catch  {
                        return .failure(HYNetError.decode(.failed(response: response, error: error)))
                    }
                } ?? .failure(HYNetError.decode(HYNetError.DecodeError.emptyData(response: response)))
                
            }
            
        }.eraseToAnyPublisher()
    }
    
    
    func mapValueCodable<T:Codable>() -> AnyPublisher<Result<T?,HYNetError>,Never>  {
        
        map { (result) -> Result<T?,HYNetError> in
         
            return  result.flatMap { (response) -> Result<T?, HYNetError> in
                guard let _data = response.data else {
                    return .failure(HYNetError.decode(HYNetError.DecodeError.emptyData(response: response)))
                }
                let decode = JSONDecoder.init()
                do {
                    let commonValue = try decode.decode(NetPublishCommonCodableResult<T>.self, from: _data)
                    switch commonValue.mapResult(url:response.response?.url?.absoluteString ) {
                        case let .success(v):
                            return.success(v)
                        case let .failure(error):
                            return .failure(error)
                     }
                } catch  {
                    return .failure(HYNetError.decode(.failed(response:response, error: error)))
                }
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    


    
}




extension AnyPublisher  where Failure == HYNetError,Output == HYRequest.Response {
    
  func mapCodable<T:Codable>() -> AnyPublisher<T,HYNetError> {
        
             flatMap { (response) -> AnyPublisher<T, HYNetError> in
                 (response.data.map {
                     let decode = JSONDecoder.init()
                     do {
                         let value = try decode.decode(T.self, from: $0)
                         return Result.success(value)
                     } catch  {
                         return Result.failure(HYNetError.decode(.failed(response: response, error: error)))
                     }
                 } ?? Result.failure(HYNetError.decode(HYNetError.DecodeError.emptyData(response: response))))
                 .publisher.eraseToAnyPublisher()
                 
             }.eraseToAnyPublisher()
     }
     
     
     

     
     func mapValueCodable<T:Codable>() -> AnyPublisher<T?,HYNetError>  {
               
         map { (response) -> Result<T?,HYNetError> in

               return  (response.data.map {
                    let decode = JSONDecoder.init()
                    do {
                        let commonValue = try decode.decode(NetPublishCommonCodableResult<T>.self, from: $0)
                        return commonValue.mapResult(url: response.response?.url?.absoluteString)
                    } catch  {
                     return .failure(HYNetError.decode(.failed(response: response, error: error)))
                    }
                 } ?? .failure(HYNetError.decode(HYNetError.DecodeError.emptyData(response: response))))
             }.eraseToAnyPublisher().flatMap { $0.publisher.eraseToAnyPublisher()}.eraseToAnyPublisher()
     }
     
     
     func mapValueCodable<T:Codable,MapError:Error>(_ mapCommonDecodeResult:@escaping (_ code:Int,_ value:T?,_ result:Result<T?,HYNetError>)->Result<T?,MapError>,mapOtherError:@escaping (HYNetError)->MapError) -> AnyPublisher<T?,MapError>  {
         
             mapError(mapOtherError)
             .map { (response) -> Result<T?,MapError> in

                 return  response.data.map {
                       let decode = JSONDecoder.init()
                       do {
                           let commonValue = try decode.decode(NetPublishCommonCodableResult<T>.self, from: $0)
                          return commonValue.map(url: response.response?.url?.absoluteString, mapCommonResult: mapCommonDecodeResult)
                       } catch  {
                         return .failure(mapOtherError(HYNetError.decode(.failed(response: response, error: error))))
                       }
                     } ?? .failure(mapOtherError(HYNetError.decode(HYNetError.DecodeError.emptyData(response: response))))
             
         }.flatMap { $0.publisher.eraseToAnyPublisher()}.eraseToAnyPublisher()
        }
    
}


extension AnyPublisher  {

    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root, completion:@escaping (Subscribers.Completion<Failure>)->()) -> AnyCancellable {
        return sink(receiveCompletion: { (end) in
            completion(end)
        }) { (value) in
            object[keyPath:keyPath] = value
        }
    }


}
