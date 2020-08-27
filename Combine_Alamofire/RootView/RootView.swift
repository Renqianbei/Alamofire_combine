//
//  RootVie.swift
//  Combine_Alamofire
//
//  Created by 任前辈 on 2020/8/21.
//  Copyright © 2020 任前辈. All rights reserved.
//

import Foundation
import SwiftUI

struct RootView:View {
    
    let state:AppState
    
    var body: some View  {
        NavigationView{
                CityListView(cityState: state.cityState).navigationBarTitle("city")
        }
    }
        
}
