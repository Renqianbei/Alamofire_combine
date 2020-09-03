//
//  CityDetail.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/26.
//  Copyright © 2020 任前辈. All rights reserved.
//
import Combine
import Foundation
import SwiftUI

class CityDetailControl:ObservableObject {
    
    @Published  var image : UIImage?
    private var cancles = [AnyCancellable]()

    @Published var progress:CGFloat = 0.0
    @Published var loading = Load.end
    deinit {
        cancles.removeAll()
        print("释放了\(self)")
    }
    
    func loadValue() {
        
        loading = .end
        progress = 0
        image = nil
        
        CityAPI.cityPic(progressPublish: { (progressPublish) in
            progressPublish.assign(to: \.progress, on: self).store(in: &self.cancles)
        }) { (picPublish) in
            picPublish.sink { (result) in
                switch result {
                case let .success(d):
                    self.image = UIImage.init(data: d)
                case let .failure(error):
                    self.loading = .tip(error.localizedDescription)
                }
                
            }.store(in: &cancles)
        }
    }

    
    
    
    
}
