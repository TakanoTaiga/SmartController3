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
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 interface:
            if interface.ifa_addr.pointee.sa_family == UInt8(AF_INET){
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "bridge100"{
                    
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
        
        NSLog("GNIH:GWA:ADDR:END" + address!)
        return address
    }
    
    public func getNetworkAddress() -> String?{
        guard let IP :String = self.getWiFiAddress() else {
            NSLog("GNIH:GNA:ConnectionTypeError")
            return nil
        }
        
        for i in 0 ..< IP.count{
            if IP.suffix(i).contains("."){
                return IP.dropLast(i)+".0"
            }
        }
        return nil
    }
}
