//
//  CityAPI_Style2.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/9/3.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Combine
import Foundation
import Alamofire


enum CitysLoadError:Error {
    
    case tip(String)
    case goToA
    case goToB
    var localizedDescription: String {
        switch self {
        case let .tip(value):
            return value
        default :
            return "页面跳转"
        }
    }
}


extension CityAPI {
    //MARK:4.Publisher 扩展方式 解析 链式codable测试
        
        
        //MARK:Never
         static func cityPublisherNeverChain() -> AnyPublisher<Result<[City]?,HYNetError>,Never> {
            
            return HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
            .firePublisherNever()
            .mapValueCodable()
            
            
    //        return HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
    //            .dataRequest().downloadProgress { (progress) in
    //            print(progress)
    //            }
    //        .firePublisherNever()
    //        .mapValueCodable()
            
        }
        //MARK:非Never
        static func cityPublisherChain3() -> AnyPublisher<[City]?,HYNetError> {
        
          return  HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars").firePublisher().mapValueCodable()
          
          
         }
        
        
        struct CityResultList:Codable,NetCodeMap {
            var _hy_Net_msg: String { return msg}
            var _hy_Net_code: Int { return code }
            var _hy_Net_value: [City]? { return data }
                    
            var code:Int = 0
            var msg:String = ""
            var data:[City]?
        }
    
    
        //MARK:除去通用码，有额外错误处理
        
        static func cityPublisherNeverChain2() -> AnyPublisher<Result<[City]?,CitysLoadError>,Never> {
            let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
     
            //2.
            let value:AnyPublisher<Result<CityResultList,HYNetError>,Never> = spark.firePublisherNever().mapCodable()
            
            let value1:AnyPublisher<Result<NetPublishCommonCodableResult<[City]?>,HYNetError>,Never> = spark.firePublisherNever().mapCodable()
            
            
           return value.map { (result) -> Result<[City]?,CitysLoadError> in
                    result.mapError({ CitysLoadError.tip($0.localizedDescription)})
                         .flatMap { (cityResult) -> Result<[City]?, CitysLoadError> in
                            if cityResult.code == 100010 {
                                return .failure(CitysLoadError.tip("100010的错误"))
                            }else if cityResult.code == 10000003 {
                                return .failure(CitysLoadError.goToA)
                            }
                            else {
                                return cityResult.mapResult(url: nil).mapError { CitysLoadError.tip($0.localizedDescription) }
                            }
                        }
                }.eraseToAnyPublisher()
            
            
        }
        
        
        
        static func cityPublisherChain4() -> AnyPublisher<[City]?,CitysLoadError> {
            let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")

            let value:AnyPublisher<CityResultList,HYNetError> = spark.firePublisher().mapCodable()

            return value.mapError({CitysLoadError.tip($0.localizedDescription)})
                .flatMap { (result) -> AnyPublisher<[City]?, CitysLoadError> in
                   
                    result.map(url: nil) { (code , citys, result) -> Result<[City]?, CitysLoadError> in
                         if code == 10000002 {
                            return .failure(CitysLoadError.tip("zidingyi"))
                        }else if code == 10000003 {
                            return .failure(CitysLoadError.goToA)
                        }
                         else {
                            return result.mapError{CitysLoadError.tip($0.localizedDescription)}
                                          
                        }
                    }.publisher.eraseToAnyPublisher()
                                    
                    
            }.eraseToAnyPublisher()
            
        }
    
    

        //新增通用错误处理，额外扩展
        static func cityPublisherChain5() -> AnyPublisher<[City]?,CitysLoadError> {
            let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
            
            return spark.firePublisher().mapValueCodable( { (code, originalValue, commonResult) -> Result<[City]?, CitysLoadError> in
                if code == 10000002 {
                    return .failure(CitysLoadError.tip("zidingyi"))
                }else if code == 10000003 {
                    return .failure(CitysLoadError.goToA)
                }
                else{
                    return commonResult.mapError{CitysLoadError.tip($0.localizedDescription)}
                }
            }) { CitysLoadError.tip($0.localizedDescription)}
       
        
        }
    
        //新增通用错误处理，额外扩展
         static func cityPublisherChain6() -> AnyPublisher<[City]?,String> {
             let spark = HYRequestSpark.init(url: "https://www.fastmock.site/mock/8ef335873e8779ca9accab37b40bf33a/first/cars")
             
             return spark.firePublisher().mapValueCodable( { (code, originalValue, commonResult) -> Result<[City]?, String> in
                 if code == 10000002 {
                     return .failure("zidingyi")
                 }
                 else{
                     return commonResult.mapError{$0.localizedDescription}
                 }
             }) { $0.localizedDescription}
        
         
         }
    
    //下载图片 带进度示例
        static func  cityPicChain(progressPublish:@escaping (AnyPublisher<CGFloat,Never>)->(),picPublish:(AnyPublisher<Result<Data?,HYNetError>,Never>)->()) {
            
            let spark = HYRequestSpark.init(url: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1598509173076&di=e12fa01f8157cc9114ccf951e13e2ef6&imgtype=0&src=http%3A%2F%2Fpic.rmb.bdstatic.com%2Fe2ebeb9c8c47d1a31de42756c54d7ac8.jpeg") {   (request: inout URLRequest) in
                request.cachePolicy = .reloadIgnoringLocalCacheData
            }
            
            let pPublish = PassthroughSubject<CGFloat,Never>.init()
            progressPublish(pPublish.eraseToAnyPublisher())
            
            
            let pub = spark.dataRequest().downloadProgress { progress in
    //                print( "当前\(progress.completedUnitCount)")
    //                print("总共\(progress.totalUnitCount)")
    //
                    let value = CGFloat(progress.completedUnitCount)/CGFloat(progress.totalUnitCount)
                    pPublish.send(value)

                    if progress.isFinished {
    //                    print("结束\(progress.totalUnitCount)")
                        pPublish.send(completion: .finished)
                    }
                }.firePublisherNever().map { $0.map(\.data)}.eraseToAnyPublisher()
            
            
            
            picPublish(pub)
        }
    
}

extension String:Error {
    
}
