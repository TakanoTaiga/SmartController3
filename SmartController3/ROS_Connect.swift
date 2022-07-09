//
//  UDPControllerClass.swift
//  SmartRobotController
//
//  Created by 高野大河 on 2021/08/14.
//

import Network
import SystemConfiguration
import CoreTelephony

struct pramROSConnect{
    var nodeIP : NWEndpoint.Host
    var deviceName : String
    var nodeName : String
    var nodeLife : Bool
    var log4NWError : String
}

class ROSConnect : ObservableObject{
    @Published var log4ROSC = pramROSConnect(nodeIP: NWEndpoint.Host(""), deviceName: "", nodeName: "", nodeLife: false, log4NWError: "Not connect")
    
    private var speaker : NWConnection? //Handler
    private var listener = try! NWListener(using: .udp, on: 64201) //Handler
    
    private let udpBackgroundQueue = DispatchQueue(label: "udpBackgroundQueue" , qos: .background , attributes: .concurrent)
    private let udpQueue = DispatchQueue(label: "UDPQueue" , qos: .utility , attributes: .concurrent)
    
    
    private var nodeCheckTimer : Timer!
    private var getNetInfoHndlr = GetNetworkInfomationHandler()
    
    func send(item : String , hostIP : NWEndpoint.Host , hostPort : NWEndpoint.Port){
        let payload = item.data(using: .utf8)!
        //var connectionCloseFlag = false
        
        self.speaker!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                NSLog("ROSC:Send:Data was sent to UDP")
                //connectionCloseFlag = true
            } else {
                NSLog("ROSC:Send:NWError:\(NWError!)")
            }
        })))
    }
    
    
    private var SROSNConnections : [NWConnection?]
    
    private func SearchROSNode(){
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            for SROSNConnection in self.SROSNConnections{
                SROSNConnection!.send(content: "WHATISNODEIP".data(using: .utf8)!, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                    if (NWError == nil) {
                        NSLog("ROSC:SROSN:Data was sent to UDP")
                    } else {
                        NSLog("ROSC:SROSN:NWError:\(NWError!)")
                    }
                })))
            }
        }
    }
    
    private func NodeCheckHandler(){
        NSLog("NodeCheckHandler:\(self.log4ROSC.nodeIP != NWEndpoint.Host(""))")
        if self.log4ROSC.nodeIP != NWEndpoint.Host(""){
            //Check Node life
            self.log4ROSC.nodeLife = false
            self.send(item: "PING" , hostIP: self.log4ROSC.nodeIP , hostPort: 64201)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                if self.log4ROSC.nodeLife{
                    //alive ros node
                    //Check Node infomation packet
                    if self.log4ROSC.deviceName == "" || self.log4ROSC.nodeName == ""{
                        self.send(item: "WHOAREYOU" , hostIP: self.log4ROSC.nodeIP , hostPort: 64201)
                        self.log4ROSC.log4NWError = "Node infomation is breaked"
                    }else{
                        //full check complete
                        self.log4ROSC.log4NWError = ""
                    }
                }else{
                    //lost ros node
                    self.log4ROSC = pramROSConnect(nodeIP: "", deviceName: "", nodeName: "", nodeLife: false, log4NWError: "Lost Node")
                    self.SearchROSNode()
                }
                }
        }else{
            //lost ros node
            self.log4ROSC = pramROSConnect(nodeIP: "", deviceName: "", nodeName: "", nodeLife: false, log4NWError: "Lost Node")
            self.SearchROSNode()
        }
    }
    
    init(){
        if let NetworkAddress = getNetInfoHndlr.getNetworkAddress(){
            NSLog("ROSC:init:NWADDR:\(NetworkAddress)")
            self.SROSNConnections = [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(1)), port: 64201, using: .udp)]
            self.SROSNConnections[0]!.start(queue: self.udpBackgroundQueue)
            for i in 1 ..< 255{
                self.SROSNConnections += [NWConnection(host: NWEndpoint.Host(NetworkAddress.dropLast(1) + String(i)), port: 64201, using: .udp)]
                self.SROSNConnections[i - 1]!.start(queue: self.udpBackgroundQueue)
            }
        }else{
            self.SROSNConnections = [NWConnection(host: "127.0.0.0", port: 64201, using: .udp)]
            self.SROSNConnections[0]!.start(queue: self.udpBackgroundQueue)
        }
        
        self.listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.udpQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    
                    let rcvDataString = String(data: data, encoding: .utf8)!
                    NSLog("ROSC:init:listener:rcvDataString:" + rcvDataString)
                    
                    if rcvDataString.contains("MYNODEIP") {
                        //node ip
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeIP = NWEndpoint.Host(String(rcvDataString.dropFirst("MYNODEIP".count)))
                            self.speaker = NWConnection(host: self.log4ROSC.nodeIP, port: 64201, using: .udp)
                            self.speaker!.start(queue: self.udpQueue)
                            self.send(item: "WHOAREYOU" , hostIP: self.log4ROSC.nodeIP , hostPort: 64201)
                            self.log4ROSC.nodeLife = true
                            self.log4ROSC.log4NWError = ""
                        }
                    }
                    
                    if rcvDataString.contains("MYNAMEIS"){
                        // Host name
                        DispatchQueue.main.async {
                            self.log4ROSC.deviceName = String(rcvDataString.dropFirst("MYNAMEIS".count))
                            self.log4ROSC.nodeLife = true
                            self.send(item: "WHATISYORNODE" , hostIP: self.log4ROSC.nodeIP , hostPort: 64201)
                        }
                    }
                    
                    if rcvDataString.contains("MYNODEIS"){
                        // Node name
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeName = String(rcvDataString.dropFirst("MYNODEIS".count))
                            self.log4ROSC.nodeLife = true
                        }
                    }
                    
                    if rcvDataString.contains("CHECK"){
                        //PING ans
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeLife = true
                            self.log4ROSC.log4NWError = ""
                        }
                    }
                    
                    newConnection.cancel()
                }else{
                    newConnection.cancel()
                }
            })
        }
        self.listener.start(queue: self.udpQueue)
        
        self.nodeCheckTimer?.invalidate()
        self.nodeCheckTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ _ in
            self.NodeCheckHandler()
        }
    }
}
