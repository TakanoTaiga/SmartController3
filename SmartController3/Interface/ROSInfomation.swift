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
            
            
//            VStack{
//                Spacer()
//
//                HStack {
//                    VStack(alignment: .leading) {
//                        if(ROSConnectHandler.nodeConnectionParameter.hostName != ""){
//                            Text("[Device]: \(ROSConnectHandler.nodeConnectionParameter.hostName)")
//                                .font(.title)
//                        }
//
//                        if(ROSConnectHandler.nodeConnectionParameter.nodeName != ""){
//                            Text("[Node]: \(ROSConnectHandler.nodeConnectionParameter.nodeName)")
//                                .padding(.bottom)
//                                .font(.title)
//                        }
//
//
//                        if(ROSConnectHandler.nodeConnectionParameter.state != ServiceState.ready){
//                            Text("[L4SC3]: Service not connect")
//                                .foregroundColor(.red)
//                        }
//                    }
//                    Spacer()
//                }
//
//                Spacer()
//
//                if ROSConnectHandler.nodeConnectionParameter.state != ServiceState.ready {
//                    Image(systemName: "xmark.circle")
//                        .foregroundColor(.red)
//                        .font(.title)
//                        .onAppear(){
////                            gccTimer?.invalidate()
////                            gccUpdateTimer?.invalidate()
//                        }
//                        .onDisappear(){
////                            GCC.NWSetup(host: ROSConnectHandler.nodeConnectionParameter.nodeIP)
////                            gccTimer?.invalidate()
////                            gccTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ _ in
////                                GCC.sendGameControllerStatus(force: false)
////                            }
////
////                            gccUpdateTimer?.invalidate()
////                            gccUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){ _ in
////                                if(GCC.needUpdate){
////                                    GCC.sendGameControllerStatus(force: true)
////                                }
////                                GCC.needUpdate = true
////                           }
//                        }
//                }
//                Spacer()
            //}
        }
        .onTapGesture {
            //ROSConnectHandler.resetStatus()
        }
    }
}
