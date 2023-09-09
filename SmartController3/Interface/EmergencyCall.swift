//
//  EmergencyCall.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/09/17.
//

import SwiftUI
import Network
import SystemConfiguration
import CoreTelephony
import TriggerSlider

struct EmergencyCall: View {
    @State private var nwcCallback : NWConnection?
    @State private var queue = DispatchQueue(label: "EmergencyCall", qos: .background , attributes: .concurrent)
    @State private var offset: CGFloat = 0.0
    
    @State private var emergencyCallStatus = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.yellow)
            
            VStack {
                Spacer()
                
                Text("EMERGENCY STOP")
                    .fontWeight(.bold)
                    .font(.title)
                    .opacity(emergencyCallStatus ? 0.5 : 1.0)
                    .animation(.easeIn(duration: 0.4), value: emergencyCallStatus)
                
                ZStack {
                    VStack {
                        Text("緊急停止措置完了")
                            .fontWeight(.bold)
                            .font(.title)
                            .offset(y: -20)
                            .opacity(emergencyCallStatus ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4), value: emergencyCallStatus)
                        Text("解除するには長押し")
                            .offset(y: -20)
                            .opacity(emergencyCallStatus ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4), value: emergencyCallStatus)
                    }
                    
                    TriggerSlider(sliderView: {
                        RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Color.red)
                            .overlay(Image(systemName: "arrow.right").font(.system(size: 30)))
                    }, textView: {
                        Text("スライドして緊急停止").foregroundColor(Color.black)
                    },
                                  backgroundView: {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(Color.orange.opacity(0.5))
                    }, offsetX: $offset,
                                  didSlideToEnd: {
                        print("Triggered right direction slider!")
                        nwcCallback = NWConnection(host: "255.255.255.255", port: 64202, using: .udp)
                        nwcCallback?.start(queue: self.queue)
                        send(item: "EMERGENCY")
                        emergencyCallStatus = true
                    }, settings: TriggerSliderSettings(sliderViewVPadding: 5, slideDirection: .right))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .opacity(emergencyCallStatus ? 0.0 : 1.0)
                    .animation(.easeIn(duration: 0.4), value: emergencyCallStatus)
                }
            }
        }
        .gesture(LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                emergencyCallStatus = false
                offset = 0
            })
    }
    
    func send(item : String){
        let payload = item.data(using: .utf8)!
        nwcCallback!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                NSLog("ROSC:Send:Data was sent to UDP")
            } else {
                NSLog("ROSC:Send:NWError:\(NWError!)")
            }
        })))
    }
}
