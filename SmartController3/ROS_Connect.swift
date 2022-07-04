//
//  UDPControllerClass.swift
//  SmartRobotController
//
//  Created by 高野大河 on 2021/08/14.
//

import Network
import SystemConfiguration
import CoreTelephony


class ROSConnect : ObservableObject{
    @Published var nodeIPHost = NWEndpoint.Host("")
    @Published var deiveName : String = ""
    @Published var nodeName : String = ""
    
    @Published var log4RCError : String = ""
    
    private var log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
    
    private var speaker : NWConnection? //Handler
    private var listener = try! NWListener(using: .udp, on: 64201) //Handler
    
    private let udpBackgroundQueue = DispatchQueue(label: "udpBackgroundQueue" , qos: .background , attributes: .concurrent)
    private let udpQueue = DispatchQueue(label: "UDPQueue" , qos: .utility , attributes: .concurrent)
    
    
    private var nodeCheckTimer : Timer!
    private var getNetInfoHndlr = GetNetworkInfomationHandler()
    
    func send(item : String , hostIP : NWEndpoint.Host , hostPort : NWEndpoint.Port){
        let payload = item.data(using: .utf8)!
        var connectionCloseFlag = false
        
        self.speaker!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("ROSC:Send:Data was sent to UDP")
                connectionCloseFlag = true
            } else {
                print("ROSC:Send:NWError:\(NWError!)")
            }
        })))
        
        while !connectionCloseFlag{()}
    }
    
    
    private var SROSNConnections : [NWConnection?]
    private var connectionBusyFlag = false
    
    private func SearchROSNode(){
        if self.connectionBusyFlag{return}
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            DispatchQueue.main.async{self.connectionBusyFlag = true}
            
            for SROSNConnection in self.SROSNConnections{
                var connectionCloseFlag = false
                
                SROSNConnection!.send(content: "WHATISNODEIP".data(using: .utf8)!, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                    if (NWError == nil) {
                        NSLog("ROSC:SROSN:Data was sent to UDP")
                        connectionCloseFlag = true
                    } else {
                        NSLog("ROSC:SROSN:NWError:\(NWError!)")
                        return;
                    }
                })))
                
                while !connectionCloseFlag{()}
            }
            DispatchQueue.main.async{self.connectionBusyFlag = false}
        }
    }
    
    private func NodeCheckHandler(){
        if log4RCInputStatus["NodeIP"]!{
            //Check Node life
            self.log4RCInputStatus["NodeLife"] = false
            self.send(item: "PING" , hostIP: self.nodeIPHost , hostPort: 64201)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                if self.log4RCInputStatus["NodeLife"]!{
                    //alive ros node
                    //Check Node infomation packet
                    if !self.log4RCInputStatus["DeiveName"]! || !self.log4RCInputStatus["NodeName"]!{
                        self.send(item: "WHOAREYOU" , hostIP: self.nodeIPHost , hostPort: 64201)
                        self.log4RCError = "Node infomation is breaked"
                    }else{
                        //full check complete
                        self.log4RCError = ""
                    }
                }else{
                    //lost ros node
                    self.log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
                    self.nodeIPHost  = ""
                    self.deiveName = ""
                    self.nodeName  = ""
                    self.log4RCError = "Lost Node"
                    self.SearchROSNode()
                }
            }
        }else{
            //lost ros node
            self.log4RCInputStatus = ["NodeIP": false,"DeiveName": false,"NodeName": false,"NodeLife":false]
            self.nodeIPHost  = ""
            self.deiveName = ""
            self.nodeName  = ""
            self.log4RCError = "Lost Node"
            self.SearchROSNode()
        }
    }
    
    init(){
        let NetworkAddress = getNetInfoHndlr.getNetworkAddress()
        NSLog("ROSC:init:NWADDR:\(NetworkAddress)")
        self.SROSNConnections = [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(1)), port: 64201, using: .udp)]
        self.SROSNConnections[0]!.start(queue: self.udpBackgroundQueue)
        for i in 2 ..< 255{
            self.SROSNConnections += [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(i)), port: 64201, using: .udp)]
            self.SROSNConnections[i - 1]!.start(queue: self.udpBackgroundQueue)
        }
        
        listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.udpQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    
                    let rcvDataString = String(data: data, encoding: .utf8)!
                    NSLog("ROSC:init:listener:rcvDataString:" + rcvDataString)
                    
                    if rcvDataString.contains("MYNODEIP") {
                        //node ip
                        DispatchQueue.main.async {
                            self.nodeIPHost = NWEndpoint.Host(String(rcvDataString.dropFirst("MYNODEIP".count)))
                            self.log4RCInputStatus["NodeIP"] = true
                            self.log4RCInputStatus["NodeLife"] = true
                            self.speaker = NWConnection(host: self.nodeIPHost, port: 64201, using: .udp)
                            self.speaker!.start(queue: self.udpQueue)
                            self.send(item: "WHOAREYOU" , hostIP: self.nodeIPHost , hostPort: 64201)
                        }
                    }
                    
                    if rcvDataString.contains("MYNAMEIS"){
                        // Host name
                        DispatchQueue.main.async {
                            self.deiveName = String(rcvDataString.dropFirst("MYNAMEIS".count))
                            self.log4RCInputStatus["DeiveName"] = true
                            self.log4RCInputStatus["NodeLife"] = true
                            
                            self.send(item: "WHATISYORNODE" , hostIP: self.nodeIPHost , hostPort: 64201)
                        }
                    }
                    
                    if rcvDataString.contains("MYNODEIS"){
                        // Node name
                        DispatchQueue.main.async {
                            self.nodeName = String(rcvDataString.dropFirst("MYNODEIS".count))
                            self.log4RCInputStatus["NodeName"] = true
                            self.log4RCInputStatus["NodeLife"] = true
                        }
                    }
                    
                    if rcvDataString.contains("CHECK"){
                        //PING ans
                        DispatchQueue.main.async {
                            self.log4RCInputStatus["NodeLife"] = true
                            self.log4RCError = ""
                        }
                    }
                    
                    newConnection.cancel()
                }else{
                    newConnection.cancel()
                }
            })
        }
        listener.start(queue: self.udpQueue)
        
        self.nodeCheckTimer?.invalidate()
        nodeCheckTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ _ in
            self.NodeCheckHandler()
        }
    }
}
