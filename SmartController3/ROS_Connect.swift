//
//  UDPControllerClass.swift
//  SmartRobotController
//
//  Created by 高野大河 on 2021/08/14.
//

import SwiftUI
import Network
import SystemConfiguration
import CoreTelephony

class ROSConnect : ObservableObject{
    @Published var NodeIP : String = ""
    @Published var DeiveName : String = ""
    @Published var NodeName : String = ""
    
    @Published var NowSeraching : Bool = true
    @Published var CanSeeNode : Bool = false
    
    @Published var SearchingLANProgress : Float = 0.0
    
    @Published var NetworkConnectionTypeErrorFlag = false
    
    private var Speaker : NWConnection? //Handler
    private var Listener = try! NWListener(using: .udp, on: 64201) //Handler
    
    private let udpSendQueue = DispatchQueue(label: "udpSendQueue" , qos: .background , attributes: .concurrent)
    private let udpRcvQueue = DispatchQueue(label: "udpRcvQueue" , qos: .background, attributes: .concurrent)
    
    private var NetworkAddress = ""
    
    func send(item : String , IP_C : String , PORT_C : String){
        let payload = item.data(using: .utf8)!
        if(IP_C != "ERROR" && PORT_C != ""){
            var connectionCloseFlag = false
            
            self.Speaker = NWConnection(host: NWEndpoint.Host(IP_C), port: .init(integerLiteral: UInt16(PORT_C)! ), using: .udp)
            self.Speaker!.start(queue: udpSendQueue)
            
            let completion = NWConnection.SendCompletion.contentProcessed{(error : NWError?) in
                NSLog("送信完了")
                connectionCloseFlag = true
            }
            self.Speaker!.send(content: payload, completion: completion)
            
            while true{
                if connectionCloseFlag{
                    self.Speaker?.cancel()
                    break
                }
            }
        }
    }
    
    private func getWiFiAddress() -> String? {
        if self.getConnectionType() != "WIFI" {
            return "NULL"
        }
        
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    private func getConnectionType() -> String {
        guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
            return "WIFI"
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if isReachable {
            if isWWAN {
                DispatchQueue.main.async {
                    self.NetworkConnectionTypeErrorFlag = true
                }
                return "Cellular"
            } else {
                return "WIFI"
            }
        } else {
            return "NoInternet"
        }
    }
    
    private func getNetworkAddress() -> String{
        let IP :String = self.getWiFiAddress()!
        
        if IP.contains("NULL"){
            return "NULL"
        }
        var counter = 0
        var dotCounter = 0
        for str in IP{
            counter += 1
            if str == "."{
                dotCounter += 1
            }
            
            if dotCounter >= 3 {
                return IP.dropLast(IP.count - counter) + "0"
            }
        }
        
        return "NULL"
    }
    
    func SearchROSNode(){
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            for i in 1 ..< 255{
                DispatchQueue.main.async {
                    self.SearchingLANProgress += 1.0
                }
                
                self.send(item: "WHATISNODEIPEND", IP_C: self.NetworkAddress.dropLast(1) + String(i), PORT_C: "64201")
                NSLog(self.NetworkAddress.dropLast(1) + String(i))
            }
            
            DispatchQueue.main.async {
                self.NowSeraching = false
            }
        }
    }
    
    
    init(){
        self.NetworkAddress = self.getNetworkAddress()
        
        Listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.udpRcvQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    
                    let rcvDataString = String(data: data, encoding: .utf8)!
                    NSLog("RCV:" + rcvDataString)
                    
                    
                    if rcvDataString.contains("MYNODEIP") {
                        //node ip
                        DispatchQueue.main.async {
                            self.NodeIP = String(rcvDataString.dropFirst("MYNODEIP".count))
                            self.CanSeeNode = true
                            self.send(item: "WHOAREYOU" , IP_C: self.NodeIP , PORT_C: "64201")
                            self.send(item: "WHATISYORNODE" , IP_C: self.NodeIP , PORT_C: "64201")
                        }
                    }
                    
                    if rcvDataString.contains("MYNAMEIS"){
                        // Host name
                        DispatchQueue.main.async {
                            self.DeiveName = String(rcvDataString.dropFirst("MYNAMEIS".count))
                        }
                    }
                    
                    if rcvDataString.contains("MYNODEIS"){
                        // Node name
                        DispatchQueue.main.async {
                            self.NodeName = String(rcvDataString.dropFirst("MYNODEIS".count))
                        }
                    }
                    
                    newConnection.cancel()
                }else{
                    newConnection.cancel()
                }
            })
        }
        Listener.start(queue: udpRcvQueue)
        
        if self.NetworkAddress != "NULL"{
            self.SearchROSNode()
        }
    }
}
