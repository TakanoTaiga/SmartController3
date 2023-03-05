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
    @State var gccTimer : Timer!
    @State var gccUpdateTimer : Timer!
        
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            
            VStack{
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        if(ROSConnectHandler.log4ROSC.deviceName != ""){
                            Text("[Device]: \(ROSConnectHandler.log4ROSC.deviceName)")
                                .font(.title)
                        }
                        
                        if(ROSConnectHandler.log4ROSC.nodeName != ""){
                            Text("[Node]: \(ROSConnectHandler.log4ROSC.nodeName)")
                                .padding(.bottom)
                                .font(.title)
                        }
                        
                        
                        if(ROSConnectHandler.log4ROSC.log4NWError != ""){
                            Text("[L4SC3]: \(ROSConnectHandler.log4ROSC.log4NWError)")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                        
                        if(ROSConnectHandler.log4ROSC.smartuiInfomation != ""){
                            Text("[S-INFO]: \(ROSConnectHandler.log4ROSC.smartuiInfomation)")
                                .font(.title)
                        }
                        
                        if(ROSConnectHandler.log4ROSC.smartuiError != ""){
                            Text("[S-EMER]: \(ROSConnectHandler.log4ROSC.smartuiError)")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                
                if ROSConnectHandler.log4ROSC.log4NWError == "Not Connected" {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.title)
                        .onAppear(){
                            gccTimer?.invalidate()
                            gccUpdateTimer?.invalidate()
                        }
                        .onDisappear(){
                            GCC.NWSetup(host: ROSConnectHandler.log4ROSC.nodeIP)
                            gccTimer?.invalidate()
                            gccTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ _ in
                                GCC.sendGameControllerStatus(force: false)
                            }
                            
                            gccUpdateTimer?.invalidate()
                            gccUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true){ _ in
                                if(GCC.needUpdate){
                                    GCC.sendGameControllerStatus(force: true)
                                }
                                GCC.needUpdate = true
                            }
                        }
                }
                Spacer()
            }
            .padding()
        }
        .onTapGesture {
            ROSConnectHandler.resetStatus()
        }
    }
}
