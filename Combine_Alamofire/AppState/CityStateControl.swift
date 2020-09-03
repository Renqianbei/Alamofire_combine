//
//  CityState.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Combine
import SwiftUI

//struct  CityState {
//     var datas:[CityAPI.City]?
//     var loading = Load.end
//}






class CityStateControl:ObservableObject {
    
    
    lazy var detail: CityDetailControl = {
        return CityDetailControl()
    }()
    deinit {
        cancles.removeAll()
        print("释放了\(self)")
    }
    
    init() {
        loadCitys()
    }
    
    private var cancles = [AnyCancellable]()
    
     @Published var datas:[CityAPI.City]?
     @Published var loading = Load.end
//    @Published var state:CityState = CityState()
    
    
    func loadCitys() {
        
        print( "地址" + NSHomeDirectory())
        
        
        if  case .loading =  loading  {
            return
        }
        
       loading = .loading
        /*
        CityAPI.cityPublisherNeverChain().sink { (result) in
            switch result {
                case let .success(citys):
                    self.state.datas = citys ?? []
                    self.state.loading = .end
                case let .failure(error):
                    self.state.loading = .tip(error.localizedDescription)
            }
        }.store(in: &cancles)
        */
        
        /*
        let loadPb = CityAPI.cityPublisherNever().share()
        loadPb.map {  result -> [CityAPI.City] in
            switch result {
                case let .success(citys):
                    return citys ?? []
                case  .failure(_):
                    return []
            }
        }.assign(to: \.datas, on: self).store(in: &cancles)
        
        
        
        loadPb.map {  result -> Load in
            switch result {
                case .success(_):
                    return .end
                case  let .failure(error):
                    return .tip(error.localizedDescription)
            }
        }.assign(to: \.loading, on: self).store(in: &cancles)
      
        */
        
        
        let netCitys =  CityAPI.cityPublisherChain5()
//
//        netCitys.sink(receiveCompletion: { (end) in
//            if case let .failure(error) = end {
//                self.loading = .tip(error.localizedDescription)
//            }
//        }) { (cs) in
//            self.datas = cs ?? []
//            self.loading = .end
//        }.store(in: &cancles)
        
        
        netCitys.assign(to: \.datas, on: self) { (end) in
            if  case let .failure(error) = end {
                self.loading = .tip(error.localizedDescription)
            }else{
                self.loading = .end
            }
           
        }.store(in: &cancles)
        
    }
    
    
    

}

