//
//  UDPControllerClass.swift
//  SmartRobotController
//
//  Created by 高野大河 on 2021/08/14.
//

//import SwiftUI
import Network
import SystemConfiguration
import CoreTelephony
import Foundation
import SwiftUI


class ROSConnect : ObservableObject{
    @Published var NodeIP_host : NWEndpoint.Host = NWEndpoint.Host("")
    @Published var DeiveName : String = ""
    @Published var NodeName : String = ""
    
    @Published var Log4RCError : String = ""
    
    private var Log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
    
    private var Speaker : NWConnection? //Handler
    private var Listener = try! NWListener(using: .udp, on: 64201) //Handler
    
    private let udpBackGroundQueue = DispatchQueue(label: "udpBackGroundQueue" , qos: .background , attributes: .concurrent)
    
    private let udpQueue = DispatchQueue(label: "UDPQueue" , qos: .utility , attributes: .concurrent)
    
    
    private var NodeCheckTimer : Timer!
    private var GetNetInfoHndlr = GetNetworkInfomationHandler()
    
    func send(item : String , IP_C : NWEndpoint.Host , PORT_C : String){
        let payload = item.data(using: .utf8)!
        if(IP_C != "ERROR" && PORT_C != ""){
            var connectionCloseFlag = false
            
            self.Speaker = NWConnection(host: IP_C, port: .init(integerLiteral: UInt16(PORT_C)! ), using: .udp)
            self.Speaker!.start(queue: self.udpQueue)
            
            self.Speaker!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                if (NWError == nil) {
                    print("Data was sent to UDP")
                    connectionCloseFlag = true
                } else {
                    
                    print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            })))
            
            while true{
                if connectionCloseFlag{
                    //self.Speaker?.restart()
                    break
                }
            }
        }
    }
    
    
    private var SROSNConnection : [NWConnection?]
    private var connectionBusyFlag = false
    
    private func SearchROSNode(){
        if self.connectionBusyFlag{return}
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            DispatchQueue.main.async{self.connectionBusyFlag = true}
            for i in 1 ..< 250{
                var connectionCloseFlag = false
                
                self.SROSNConnection[i]!.send(content: "WHATISNODEIP".data(using: .utf8)!, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                    if (NWError == nil) {
                        NSLog("Data was sent to UDP")
                        connectionCloseFlag = true
                    } else {
                        
                        NSLog("ERROR! Error when data (Type: Data) sending. NWError:\(NWError!) , IP:\(i)")
                        return;
                    }
                })))
                
                while true{
                    if connectionCloseFlag{
                        //self.SROSNConnection[i]?.restart()
                        break
                    }
                }
            }
            DispatchQueue.main.async{self.connectionBusyFlag = false}
        }
    }
    
    private func NodeCheckHandler(){
        if Log4RCInputStatus["NodeIP"]!{
            //Check Node life handler
            self.Log4RCInputStatus["NodeLife"] = false
            self.send(item: "PING" , IP_C: self.NodeIP_host , PORT_C: "64201")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                if self.Log4RCInputStatus["NodeLife"]!{
                    //alive ros node
                    //Check Node infomation packet
                    if !self.Log4RCInputStatus["DeiveName"]! || !self.Log4RCInputStatus["NodeName"]!{
                        self.send(item: "WHOAREYOU" , IP_C: self.NodeIP_host , PORT_C: "64201")
                        self.Log4RCError = "Node infomation is breaked"
                    }else{
                        //full check complete
                        self.Log4RCError = ""
                    }
                }else{
                    //lost ros node
                    self.Log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
                    self.NodeIP_host  = ""
                    self.DeiveName = ""
                    self.NodeName  = ""
                    self.Log4RCError = "Lost Node"
                    self.SearchROSNode()
                }
            }
        }else{
            //lost ros node
            self.Log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
            self.NodeIP_host  = ""
            self.DeiveName = ""
            self.NodeName  = ""
            self.Log4RCError = "Lost Node"
            self.SearchROSNode()
        }
        
        
    }
    
    private func resetNodeInfomation(){
        self.NodeIP_host  = NWEndpoint.Host("")
        self.DeiveName = ""
        self.NodeName  = ""
        //self.CheckItems = 0
    }
    
    
    
    init(){
        let NetworkAddress = GetNetInfoHndlr.getNetworkAddress()
        
        self.SROSNConnection = [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(1)), port: 64201, using: .udp)]
        self.SROSNConnection[0]!.start(queue: self.udpBackGroundQueue)
        for i in 2 ..< 255{
            self.SROSNConnection += [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(i)), port: 64201, using: .udp)]
            self.SROSNConnection[i - 1]!.start(queue: self.udpBackGroundQueue)
        }
        
        Listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.udpQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    
                    let rcvDataString = String(data: data, encoding: .utf8)!
                    NSLog("RCV:" + rcvDataString)
                    
                    
                    if rcvDataString.contains("MYNODEIP") {
                        //node ip
                        DispatchQueue.main.async {
                            self.NodeIP_host = NWEndpoint.Host(String(rcvDataString.dropFirst("MYNODEIP".count)))
                            self.Log4RCInputStatus["NodeIP"] = true
                            self.Log4RCInputStatus["NodeLife"] = true
                            self.Speaker = NWConnection(host: self.NodeIP_host, port: 64201, using: .udp)
                            self.Speaker!.start(queue: self.udpQueue)
                            self.send(item: "WHOAREYOU" , IP_C: self.NodeIP_host , PORT_C: "64201")
                        }
                    }
                    
                    if rcvDataString.contains("MYNAMEIS"){
                        // Host name
                        DispatchQueue.main.async {
                            self.DeiveName = String(rcvDataString.dropFirst("MYNAMEIS".count))
                            self.Log4RCInputStatus["DeiveName"] = true
                            self.Log4RCInputStatus["NodeLife"] = true
                            
                            self.send(item: "WHATISYORNODE" , IP_C: self.NodeIP_host , PORT_C: "64201")
                        }
                    }
                    
                    if rcvDataString.contains("MYNODEIS"){
                        // Node name
                        DispatchQueue.main.async {
                            self.NodeName = String(rcvDataString.dropFirst("MYNODEIS".count))
                            self.Log4RCInputStatus["NodeName"] = true
                            self.Log4RCInputStatus["NodeLife"] = true
                        }
                    }
                    
                    if rcvDataString.contains("CHECK"){
                        //PING ans
                        DispatchQueue.main.async {
                            self.Log4RCInputStatus["NodeLife"] = true
                            self.Log4RCError = ""
                        }
                    }
                    
                    newConnection.cancel()
                }else{
                    newConnection.cancel()
                }
            })
        }
        Listener.start(queue: self.udpQueue)
        
        self.NodeCheckTimer?.invalidate()
        NodeCheckTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ _ in
            self.NodeCheckHandler()
        }
    }
}
