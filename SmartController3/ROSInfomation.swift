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
    @State var deviceName = ""
    @State var ROSConnectionTimer : Timer!
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            VStack{
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(ROSConnectHandler.NodeName)
                            .font(.title)
                        Text(ROSConnectHandler.DeiveName)
                            .opacity(0.5)
                    }
                    Spacer()
                }
                
                Spacer()
                
                if ROSConnectHandler.NetworkConnectionTypeErrorFlag{
                    HStack{
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("Network connection type error")
                    }
                }else{
                    if ROSConnectHandler.SearchingLANProgress < 254 {
                        ProgressView()
                    }else{
                        if ROSConnectHandler.CanSeeNode {
                            HStack{
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text("Scan complete")
                                    .onAppear(){
                                        GCC.NodeIP = ROSConnectHandler.NodeIP
                                    }
                            }
                        }else{
                            HStack{
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                                Text("Node not found")
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
