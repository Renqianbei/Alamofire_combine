//
//  HYNetCommonResult.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation

//MARK:不解析类型
extension Data:HyCodeExplain,HyDecodeSerializer {

    static func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?) throws -> Self {
        guard let _data = data else {
            throw HYNetError.decode(.emptyData(response:HYRequest.Response.init(response: response)))
        }
        return _data
        
    }
        
    var result: Result<Self, HYNetError> {
        return .success(self)
    }
    
}


//MARK:Codable 通用层类型
class NetCommonCodableResult<T:Codable>:Codable {
    var code:Int = 0
    var msg:String = ""
    var data:T?
    var ___requestUrlString:String?
    
}

extension NetCommonCodableResult:HyCodeExplain{
    
    var result: Result<T?, HYNetError>{
        if code == 200 {
            return .success(data)
        }else {
            if ___requestUrlString?.hasPrefix("特定地址") ?? false {
                return .failure(HYNetError.ServerResultError(code: code, msg: msg, mapMsg: "自定义错误\(code)"))
            }else{
                return .failure(HYNetError.ServerResultError(code: code, msg: msg, mapMsg: "自定义错误\(code)"))
            }
        }
    }
    
    
}




extension NetCommonCodableResult:HyDecodeSerializer {

       static func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?) throws -> Self {
           
        
        guard let _data = data else {
            throw HYNetError.decode(.emptyData(response: HYRequest.Response.init(response: response)))
        }
                
        let decode = JSONDecoder.init()
        do {
            let value = try decode.decode(self, from: _data)
            value.___requestUrlString = request?.url?.absoluteString
            return value
        } catch  {
            throw HYNetError.decode(HYNetError.DecodeError.failed(response: HYRequest.Response.init(data: _data, response: response), error: error))
        }
       
        
    }
}



//MARK:quick get Codable解析器

protocol MYQuickCodableProtocol:Codable {
    static var codableSerializer:HYNetSerializer<NetCommonCodableResult<Self>> {get}
    static var arrayCodableSerializer:HYNetSerializer<NetCommonCodableResult<[Self]>> {get}
}

extension MYQuickCodableProtocol {
    static var codableSerializer:HYNetSerializer<NetCommonCodableResult<Self>> {
        return HYNetSerializer<NetCommonCodableResult<Self>>()
    }
    static var arrayCodableSerializer:HYNetSerializer<NetCommonCodableResult<[Self]>> {
        return HYNetSerializer<NetCommonCodableResult<[Self]>>()
    }


}
