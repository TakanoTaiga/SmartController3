//
//  NodeConnectionMain.swift
//  SmartController3
//
//  Created by Taiga Takano on 2021/08/14.
//

import Network
import CoreTelephony

class NodeConnection : ObservableObject{
    @Published private (set) public var nodeConnectionParameter = NodeConnectionParameter()
    @Published private (set) public var nodeInfomation = NodeInfomation()
    @Published private (set) public var smartUILabel = SmartUILabel()
    
    private var nodeConnector : NWConnection?
    private var nodeSearcher : NWConnection?
    private var listener = try! NWListener(using: .udp, on: 64201)
    
    private let nodeConnectionQueue = DispatchQueue(label: "UDPQueue" , qos: .userInteractive , attributes: .concurrent)
    
    private var nodeCheckTimer : Timer!
    
    private func SearchROSNode(){
        if(self.nodeConnectionParameter.state == ServiceState.ready){return}
        if(self.nodeSearcher?.state != NWConnection.State.ready){
            NSLog("nodeSearcher state is not ready")
            self.nodeSearcher = NWConnection(host: "255.255.255.255", port: 64201, using: .udp)
            self.nodeSearcher!.start(queue: self.nodeConnectionQueue)
            return
        }
        
        var sendItem = NodeConnectionKey.searchNode.rawValue
        let sendData = Data(bytes: &sendItem, count: MemoryLayout<UInt8>.size)
        self.nodeSearcher!.send(content: sendData,
                                 completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError != nil) {
                NSLog("ROSC:SROSN:NWError:\(NWError!)")
                DispatchQueue.main.async {
                    self.nodeSearcher = NWConnection(host: "255.255.255.255", port: 64201, using: .udp)
                    self.nodeSearcher!.start(queue: self.nodeConnectionQueue)
                }
            }
        })))
    }
    
    private func SendnNodeConnector(data : Data){
        if(self.nodeConnector?.state != NWConnection.State.ready){
            NSLog("nodeConnector state is not ready")
            return
        }
        
        self.nodeConnector!.send(content: data,
                           completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError != nil) {
                NSLog("ROSC:Send:NWError:\(NWError!)")
            }
        })))
    }
    
    private func NodeCheckHandler(){
        if(self.nodeConnectionParameter.state != ServiceState.ready){return}
        
        self.nodeConnectionParameter.state = ServiceState.preparing
        var sendItem = NodeConnectionKey.pingRequest.rawValue
        let sendData = Data(bytes: &sendItem, count: MemoryLayout<UInt8>.size)
        self.SendnNodeConnector(data: sendData)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            if(self.nodeConnectionParameter.state != ServiceState.ready){
                self.nodeConnectionParameter = NodeConnectionParameter()
                self.smartUILabel = SmartUILabel()
                self.nodeInfomation = NodeInfomation()
            }
        }
    }
    
    private func NodeInfoCollector(){
        if(self.nodeConnectionParameter.state != ServiceState.ready){return}
        if(self.nodeInfomation != NodeInfomation()){return}
        
        var sendItem = NodeConnectionKey.nodeInfoRequest.rawValue
        let sendData = Data(bytes: &sendItem, count: MemoryLayout<UInt8>.size)
        self.SendnNodeConnector(data: sendData)
    }
    
    
    init(){
        self.nodeSearcher = NWConnection(host: "255.255.255.255", port: 64201, using: .udp)
        self.nodeSearcher!.start(queue: self.nodeConnectionQueue)
        
        self.listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.nodeConnectionQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    let responseData = data.withUnsafeBytes{ $0.load( as: ResponseData.self ) } as ResponseData
                    logNodeConnectionKey(key: responseData.header)
                    
                    if(responseData.header == NodeConnectionKey.ipResponse.rawValue){
                        let ipAddr = data.withUnsafeBytes{ $0.load( as: IpVectorData.self ) } as IpVectorData
                        let ipAddrStr = "\(ipAddr.ip_addr_0).\(ipAddr.ip_addr_1).\(ipAddr.ip_addr_2).\(ipAddr.ip_addr_3)"
                        NSLog(ipAddrStr)

                        DispatchQueue.main.async {
                            self.nodeConnectionParameter.state = ServiceState.ready
                            self.nodeConnectionParameter.nodeIP = NWEndpoint.Host(ipAddrStr)
                            self.nodeConnector = NWConnection(host: self.nodeConnectionParameter.nodeIP, port: 64201, using: .udp)
                            self.nodeConnector!.start(queue: self.nodeConnectionQueue)
                        }
                    }
                    
                    if(responseData.header == NodeConnectionKey.pingResponse.rawValue){
                        DispatchQueue.main.async {
                            self.nodeConnectionParameter.state = ServiceState.ready
                        }
                    }
                    
                    if(responseData.header == NodeConnectionKey.nodeInfoResponse.rawValue){
                        DispatchQueue.main.async {
                            self.nodeConnectionParameter.state = ServiceState.ready
                            if(data.count < 96){
                                return
                            }
                            self.nodeInfomation.hostName = ""
                            for i in 1...16{
                                self.nodeInfomation.hostName += uint8ToString(char: data[i])
                            }
                            
                            self.smartUILabel.buttonA = ""
                            for i in 17...32{
                                self.smartUILabel.buttonA += uint8ToString(char: data[i])
                            }
                            
                            self.smartUILabel.buttonB = ""
                            for i in 33...48{
                                self.smartUILabel.buttonB += uint8ToString(char: data[i])
                            }
                            
                            self.smartUILabel.slider = ""
                            for i in 49...64{
                                self.smartUILabel.slider += uint8ToString(char: data[i])
                            }
                        }
                    }
                }
                newConnection.cancel()
            })
        }
        self.listener.start(queue: self.nodeConnectionQueue)
        
        self.nodeCheckTimer?.invalidate()
        self.nodeCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true){ _ in
            self.SearchROSNode()
            self.NodeInfoCollector()
            self.NodeCheckHandler() // RUN IT LAST
        }
    }
}
