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
        //MARK:todo
        let config = URLSessionConfiguration.af.default
//        config.requestCachePolicy = .useProtocolCachePolicy
        session = Alamofire.Session.init(configuration: config)
    }
    
    
    
    //MARK:1.Result,Never
    
    func requestPublish<Serializer:ResponseSerializer>(requestConvert:URLRequestConvertible,serializer:Serializer, interceptor: RequestInterceptor? = nil) -> AnyPublisher<Result<Serializer.SerializedObject.Value,HYNetError>,Never>  where Serializer.SerializedObject : HyCodeExplain  {
           
        return  requestPublish(request: request(requestConvert,interceptor: interceptor), serializer: serializer)

    }
    
    func requestPublish<Serializer:ResponseSerializer>(request:DataRequest,serializer:Serializer) -> AnyPublisher<Result<Serializer.SerializedObject.Value,HYNetError>,Never>  where Serializer.SerializedObject : HyCodeExplain  {
           
        return  request.publishResponse(using: serializer, on: DispatchQueue.main).result().map { (result) -> Result<Serializer.SerializedObject.Value,HYNetError> in
            
            result.mapError { HYNetError(afError: $0)}.flatMap { $0.result }
            
        }.eraseToAnyPublisher()

    }
    
    
    
    //MARK:2. Value,HYNetError
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
    
    
    
    
    struct Response {
        var data:Data?
        var response:URLResponse?
    }
    //MARK:无解析  返回 response
    //MARK:3.Never
    func requestPublish(requestConvert:URLRequestConvertible) -> AnyPublisher<Result<Response,HYNetError>,Never> {
        return requestPublish(request: request(requestConvert))
        
    }
    
    
    func requestPublish(request:DataRequest) -> AnyPublisher<Result<Response,HYNetError>,Never> {
        
        request.publishUnserialized().result().map { $0.map { [weak request] in Response.init(data: $0, response: request?.response) }.mapError({HYNetError.init(afError: $0)})
        }.eraseToAnyPublisher()
        
    }
    
    
    
    //MARK:4.HYNetError
    func requestPublish(requestConvert:URLRequestConvertible) -> AnyPublisher<Response,HYNetError> {
        return requestPublish(request: request(requestConvert))
        
    }
    
    
    func requestPublish(request:DataRequest) -> AnyPublisher<Response,HYNetError> {
        
        request.publishUnserialized()
            .value()
            .mapError(HYNetError.init(afError:))
            .map { [weak request] in Response.init(data: $0, response: request?.response) }
            .eraseToAnyPublisher()
    }
    
    
    
    
    
    
    func request(_ requestConvert:URLRequestConvertible,customSession:Session? = nil, interceptor: RequestInterceptor? = nil) -> DataRequest {
        
        let dr =  (customSession ?? session).request(requestConvert,interceptor: interceptor).validate(statusCode: 200..<299).validate(contentType: ["application/json","image/jpeg"])
            
        
        return  dr
    }
    

    
}

