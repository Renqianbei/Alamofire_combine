//
//  CityContentView.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import SwiftUI

struct CityListView:View {
    
    @ObservedObject var cityState:CityStateControl
    
    var datas:[CityAPI.City] {
        return cityState.datas ?? []
    }
    
    var loading:Load {
        return cityState.loading
    }
    
    var body: some View  {

                    VStack {
                        Text(loading.debug).font(.title)
                        Button.init("Retry") {
                            self.cityState.loadCitys()
                        }.font(.subheadline)
                        List(datas,id:\.zip) {
                            Button.init("") {
                                self.cityState.detail.loadValue()
                            }
                            NavigationLink.init($0.name,destination: CityDetailView(city: $0,detail: self.cityState.detail).navigationBarTitle($0.name))
                        }
                        
                    }
    }        
        
}

struct CityContentView_Previews : PreviewProvider {

    static var previews: some View {
        NavigationView {
            CityListView(cityState:CityStateControl())
        }
    }
}
