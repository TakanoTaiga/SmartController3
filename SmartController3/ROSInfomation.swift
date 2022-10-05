//
//  ROSInfomation.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import SwiftUI
import AVFoundation

struct ROSInfomation: View {
    @ObservedObject var ROSConnectHandler : ROSConnect
    @ObservedObject var GCC : GameControllerClass
    @State var gccTimer : Timer!
    @State var gccUpdateTimer : Timer!
    
    let synthesizer = AVSpeechSynthesizer()
    
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
                        }
                        
                        if(ROSConnectHandler.log4ROSC.nodeName != ""){
                            Text("[Node]: \(ROSConnectHandler.log4ROSC.nodeName)")
                                .padding(.bottom)
                        }
                        
                        
                        if(ROSConnectHandler.log4ROSC.log4NWError != ""){
                            Text("[L4SC3]: \(ROSConnectHandler.log4ROSC.log4NWError)")
                                .foregroundColor(.red)
                        }
                        
                        if(ROSConnectHandler.log4ROSC.smartuiInfomation != ""){
                            Text("[S-INFO]: \(ROSConnectHandler.log4ROSC.smartuiInfomation)")
                        }
                        
                        if(ROSConnectHandler.log4ROSC.smartuiError != ""){
                            Text("[S-EMER]: \(ROSConnectHandler.log4ROSC.smartuiError)")
                                .foregroundColor(.red)
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
                            let utterance = AVSpeechUtterance(string: "接続が完了しました")
                            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                            utterance.rate = 0.5
                            synthesizer.speak(utterance)
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
