//
//  EmergencyCall.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/09/17.
//

import SwiftUI
import Network
import SystemConfiguration
import CoreTelephony

struct EmergencyCall: View {
    @State var nwcCallback : NWConnection?
    @State var queue = DispatchQueue(label: "EmergencyCall", qos: .background , attributes: .concurrent)
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.yellow)
            
            VStack{
                Text("EMERGENCY")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Button(action: {
                    nwcCallback = NWConnection(host: "255.255.255.255", port: 64202, using: .udp)
                    nwcCallback?.start(queue: self.queue)
                    send(item: "EMERGENCY")
                    
                }, label: {
                    Circle()
                        .frame(width: 90)
                        .foregroundColor(.red)
                        .shadow(radius: 5)
                })
                
                Text("STOP")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
        }
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
