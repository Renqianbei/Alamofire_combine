//
//  CityDetailView.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import SwiftUI


struct TestModel {
    var id:String {
        return  "卧槽" + name
    }
    var name:String
}


struct  CityDetailView: View {
    let city:CityAPI.City
   
    @ObservedObject var detail:CityDetailControl
    var body: some View {
        
        VStack{
        
        Text(detail.loading.debug)
        Text("进度\(detail.progress)")
        Image.init(uiImage: detail.image ?? UIImage()).frame( width:300*detail.progress,height: 100, alignment: Alignment.center).clipped()
        
            
            
        ForEach.init([city.name,city.city,city.country,city.zip].map {
            return TestModel.init(name: $0)
        }, id: \.id) {
            Text($0.name)
        }
            
        }
        
       
        
    }
}
