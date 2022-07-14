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
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            VStack{
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(ROSConnectHandler.log4ROSC.nodeName)
                            .font(.title)
                        Text(ROSConnectHandler.log4ROSC.deviceName)
                            .opacity(0.5)
                    }
                    Spacer()
                }
                
                Spacer()
                
                if ROSConnectHandler.log4ROSC.log4NWError == "" {
                    HStack{
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Scan complete")
                            .onAppear(){
                                GCC.NWSetup(host: ROSConnectHandler.log4ROSC.nodeIP)
                                gccTimer?.invalidate()
                                gccTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true){ _ in
                                    GCC.sendGameControllerStatus()
                                }
                            }
                            .onDisappear(){
                                gccTimer?.invalidate()
                            }
                    }
                }else{
                    HStack{
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text(ROSConnectHandler.log4ROSC.log4NWError)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
