//
//  HYRequest.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/19.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import Alamofire
import Combine


class HYRequest {
        
    static let shared:HYRequest = HYRequest()
    let session:Alamofire.Session!
    private init() {
        
        let config = URLSessionConfiguration.af.default
//        config.requestCachePolicy = .useProtocolCachePolicy
        session = Alamofire.Session.init(configuration: config)
    }
    
    //1:Never
    
    func requestPublish<Serializer:ResponseSerializer>(requestConvert:URLRequestConvertible,serializer:Serializer, interceptor: RequestInterceptor? = nil) -> AnyPublisher<Result<Serializer.SerializedObject.Value,HYNetError>,Never>  where Serializer.SerializedObject : HyCodeExplain  {
           
        return  requestPublish(request: request(requestConvert,interceptor: interceptor), serializer: serializer)

    }
    
    func requestPublish<Serializer:ResponseSerializer>(request:DataRequest,serializer:Serializer) -> AnyPublisher<Result<Serializer.SerializedObject.Value,HYNetError>,Never>  where Serializer.SerializedObject : HyCodeExplain  {
           
        return  request.publishResponse(using: serializer, on: DispatchQueue.main).result().map { (result) -> Result<Serializer.SerializedObject.Value,HYNetError> in
            
            result.mapError { HYNetError(afError: $0)}.flatMap { $0.result }
            
        }.eraseToAnyPublisher()

    }
    
    
    
    //2:HYNetError
    func requestPublish<Serializer:ResponseSerializer>(requestConvert:URLRequestConvertible,serializer:Serializer, interceptor: RequestInterceptor? = nil) -> AnyPublisher<Serializer.SerializedObject.Value,HYNetError>  where Serializer.SerializedObject : HyCodeExplain  {
        
        return requestPublish(request: request(requestConvert,interceptor: interceptor), serializer: serializer)
        
    }
    func requestPublish<Serializer:ResponseSerializer>(request:DataRequest,serializer:Serializer) -> AnyPublisher<Serializer.SerializedObject.Value,HYNetError>  where Serializer.SerializedObject : HyCodeExplain  {
                   
        
        return  request.publishResponse(using: serializer, on: DispatchQueue.main).value().mapError {
            HYNetError(afError: $0)
      }.flatMap { (result) -> AnyPublisher<Serializer.SerializedObject.Value,HYNetError> in
        
        switch result.result {
            case  let .success(value):
                return CurrentValueSubject.init(value).eraseToAnyPublisher()
            case let .failure(error):
                return Fail.init(error: error).eraseToAnyPublisher()
        }
            
      }.eraseToAnyPublisher()

            
        
    }
    
    
    
    
    
    
    
    func request(_ requestConvert:URLRequestConvertible, interceptor: RequestInterceptor? = nil) -> DataRequest {
        
        let dr =  session.request(requestConvert,interceptor: interceptor).validate(statusCode: 200..<299).validate(contentType: ["application/json","image/jpeg"])
            
        
        return  dr
    }
    

    
}