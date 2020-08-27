//
//  CityState.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Combine

class CityController:ObservableObject {
    
    deinit {
        print("释放了\(self)")
    }
    
    init() {
        loadCitys()
    }
    var cancles = [AnyCancellable]()
    
    
   @Published var datas = [CityAPI.City]()
    
    var loading = Load.end
    
    func loadCitys() {
        
        loading = .loading
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
        
        
    }
    
    
}
