//
//  NetworkHandler.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/07/02.
//

import Network
import SystemConfiguration
import CoreTelephony
import Foundation

class GetNetworkInfomationHandler{
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
                return "Cellular"
            } else {
                return "WIFI"
            }
        } else {
            return "NoInternet"
        }
    }
    
    public func getNetworkAddress() -> String{
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
}
