//
//  FirstCombine.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/19.
//  Copyright © 2020 任前辈. All rights reserved.
//
import Combine
import Foundation
import Alamofire


enum CityError:Error {
    
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case let .custom(value):
            return value
        }
    }
}

class CityAPI {
    
    
    
    struct City:MYQuickCodableProtocol {        
        let name:String
        let city:String
        let country:String
        let zip:String
        
    }
    

   static func citys(success:@escaping ([City]?)->(),failed:@escaping (HYNetError?)->())  {
        
    let url = "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars"
    let spark = HYRequestSpark.init(url: url)
    let dataRequest = HYRequest.shared.request(spark).response(responseSerializer: City.arrayCodableSerializer) {
        response in
        switch response.result {
        case let .success(model):
            success(model.data)
        case let .failure(af):
            failed(HYNetError.init(afError: af))
        }
    }
    
    dataRequest.resume()
    
    
    }
    
   static func citysNever(completetion:@escaping(Result<[City]?,HYNetError>)->())  {
        
        let url = "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars"
        let spark = HYRequestSpark.init(url: url)
        let dataRequest = HYRequest.shared.request(spark).response(responseSerializer: City.arrayCodableSerializer) {
            response in
            completetion(response.result.map({ $0.data
            }).mapError(HYNetError.init(afError:)))
        }
        
        dataRequest.resume()
    
    }
    
    
    
    
//MARK:返回publisher
    
   //MARK:1.带错误
   static func cityPublisher() -> AnyPublisher<[City]?,HYNetError> {
    
        let url = "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars"
        let spark = HYRequestSpark.init(url: url)
        return HYRequest.shared.requestPublish(requestConvert: spark, serializer: City.arrayCodableSerializer)
   
    }
    
    
   //MARK:2.不带错误，建议方式
   static func cityPublisherNever() -> AnyPublisher<Result<[City]?,HYNetError>,Never> {
       
    let url = "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars"
    
//    return HYRequest.shared.requestPublish(requestConvert: HyRequestSpark(url: url), serializer: City.arrayCodableSerializer);
        
    
    
    let spark = HYRequestSpark.init(url: url) {  (  request :inout URLRequest) in
//        request.url = URL.init(string: "")
//        request.cachePolicy = .returnCacheDataElseLoad
//        request.addValue("W/\"8d0-0s0jbzDFKTohM9A3TYDNDK/LBGY\"", forHTTPHeaderField: "If-None-Match")
//        request.addValue("xxxxx", forHTTPHeaderField: "If-None-Match")
    }
    
//    soul.parameters = ["hello":["2","3","4"],"w":true]
//
//    soul.encoding = URLEncoding.init(destination: URLEncoding.Destination.methodDependent, arrayEncoding: URLEncoding.ArrayEncoding.brackets, boolEncoding: URLEncoding.BoolEncoding.numeric)
//
//    let s = try? soul.asURLRequest().url?.absoluteString
//    print(s)
    
    
    //自定义adapter和retry
    let customcepter = Interceptor.init(adaptHandler: { (request, session, adapt) in
        adapt(.success(request))
    }) { (request, session, error, retry) in
        print(error)
        retry(.doNotRetry)
    }
    
    
    let dr = HYRequest.shared.request(spark,interceptor: customcepter)
    
    //缓存测试
    dr.cacheResponse(using: ResponseCacher.init(behavior: .modify({ (task, oCache) -> CachedURLResponse? in
        return oCache
        /*
        let response = oCache.response as! HTTPURLResponse
        var headers = response.allHeaderFields as! [String:String]
            headers["Cache Control"] = "max-age=10"
            print(headers["Etag"] ?? "")
        let newHttpResponse = HTTPURLResponse.init(url: response.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)

        let cacherRp = CachedURLResponse.init(response: newHttpResponse!, data: testValue.data(using: String.Encoding.utf8)!)

         return cacherRp
         */
    })))
        
    
    
    return HYRequest.shared.requestPublish(request: dr, serializer: City.arrayCodableSerializer)
            
    
    }
    
    
    
    
    //MARK:3.下载图片 带进度示例
    static func  cityPic(progressPublish:@escaping (AnyPublisher<CGFloat,Never>)->(),picPublish:(AnyPublisher<Result<Data,HYNetError>,Never>)->()) {
        
        let spark = HYRequestSpark.init(url: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1598509173076&di=e12fa01f8157cc9114ccf951e13e2ef6&imgtype=0&src=http%3A%2F%2Fpic.rmb.bdstatic.com%2Fe2ebeb9c8c47d1a31de42756c54d7ac8.jpeg") {   (request: inout URLRequest) in
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        
        let pPublish = PassthroughSubject<CGFloat,Never>.init()
       
        let dr = HYRequest.shared.request(spark).downloadProgress { progress in
//                print( "当前\(progress.completedUnitCount)")
//                print("总共\(progress.totalUnitCount)")
//
                let value = CGFloat(progress.completedUnitCount)/CGFloat(progress.totalUnitCount)
                pPublish.send(value)

                if progress.isFinished {
//                    print("结束\(progress.totalUnitCount)")
                    pPublish.send(completion: .finished)
                }
        }
        
        progressPublish(pPublish.eraseToAnyPublisher())
        
        picPublish(HYRequest.shared.requestPublish(request: dr, serializer: HYNetSerializer<Data>()))
    }
    
 
    
    
//MARK:Publisher 扩展方式 解析 链式codable测试
    
    struct CityResultList:Codable,NetCodeMap {
        var _hy_Net_code: Int {
            return code
        }
        
        var _success_value: [CityAPI.City]? {
            return data
        }
        
        typealias Value = [City]?
        
        var code:Int = 0
        var msg:String = ""
        var data:[City]?
    }
    
     static func cityPublisherNeverChain() -> AnyPublisher<Result<[City]?,HYNetError>,Never> {
            let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
            //1.
            return HYRequest.shared.requestPublish(requestConvert: spark).mapValueCodable(url: nil)
    }
    
    
    static func cityPublisherNeverChain2() -> AnyPublisher<Result<[City]?,CityError>,Never> {
        let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
 
        //2.
        let value:AnyPublisher<Result<CityResultList,HYNetError>,Never> = HYRequest.shared.requestPublish(requestConvert: spark).mapCodable()
        
        let value1:AnyPublisher<Result<NetPublishCommonCodableResult<[City]?>,HYNetError>,Never> = HYRequest.shared.requestPublish(requestConvert: spark).mapCodable()
        
        
       return value.map { (result) -> Result<[City]?,CityError> in
            
            result.mapError({ CityError.custom($0.localizedDescription)}).flatMap { (cityResult) -> Result<[City]?, CityError> in
                        if cityResult.code == 100010 {
                            return .failure(CityError.custom("hello 错误率"))
                        }else {
                            return cityResult.mapCode(url: nil).mapError { CityError.custom($0.localizedDescription) }
                        }
                    }
            }.eraseToAnyPublisher()
        
        
    }

    
    
}


let testValue:String = """
{
"code": 200,
"msg": "成功",
"data": [
  {
    "name": "青海省",
    "city": "安徽省 芜湖市",
    "country": "四川省 达州市 开江县",
    "zip": "174432"
  }
        ]
}
"""
