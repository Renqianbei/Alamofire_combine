//
//  AppState.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import Combine

class AppState {
    
    var cityState: CityStateControl = CityStateControl()
    
}

enum Load {
    case loading
    case end
    case tip(String)
    
    var debug:String {
        if case let .tip(v) = self {
            return v
        }
        switch self {
         case let .tip(v):
            return v
        case  .end:
            return "闲置"
        case  .loading:
            return "加载中"
        }
    }
}

