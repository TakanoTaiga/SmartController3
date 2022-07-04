//
//  ROSInfomation.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import SwiftUI

struct ROSInfomation: View {
    @ObservedObject var ROSConnectHandler : ROSConnect
    @ObservedObject var GCC : GameControllerClass
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            VStack{
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(ROSConnectHandler.nodeName)
                            .font(.title)
                        Text(ROSConnectHandler.deiveName)
                            .opacity(0.5)
                    }
                    Spacer()
                }
                
                Spacer()
                
                if ROSConnectHandler.log4RCError == "" {
                    HStack{
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Scan complete")
                            .onAppear(){
                                GCC.NodeIP_host = ROSConnectHandler.nodeIPHost
                            }
                    }
                }else{
                    HStack{
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text(ROSConnectHandler.log4RCError)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
