//
//  ROSInfomation.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI

struct ROSInfomation: View {
    @ObservedObject var ROSConnectHandler : NodeConnection
    @ObservedObject var GCC : GameControllerClass
    @State var gccTimer : Timer!
    @State var gccUpdateTimer : Timer!
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.brown)
                .opacity(0.1)
        }
    }
}
