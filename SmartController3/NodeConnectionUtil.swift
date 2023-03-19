//
//  NodeConnectionUtil.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/03/08.
//

import Network
import SwiftUI

enum ServiceState{
    case preparing
    case ready
    case failed
}

struct NodeConnectionParameter{
    var nodeIP = NWEndpoint.Host("")
    var state = ServiceState.failed
}

struct NodeInfomation : Equatable{
    var hostName = ""
}

enum NodeConnectionKey: UInt8{
    case searchNode = 47
    case pingRequest = 98
    case pingResponse = 87
    case ipResponse = 75
    case nodeInfoRequest = 23
    case nodeInfoResponse = 25
    case gamepadValueRequest = 12
}

struct ResponseData{
    var header : UInt8 = 0
}

struct GamepadResponseData{
    var header : UInt8 = 0
    var gamepadData = GamepadValue()
    var smartUIData = SmartUIValue()
}

struct IpVectorData{
    var header : UInt8 = 0
    var ip_addr_0 : Int16 = 0
    var ip_addr_1 : Int16 = 0
    var ip_addr_2 : Int16 = 0
    var ip_addr_3 : Int16 = 0
}

struct NodeInfoData{
    var header : UInt8 = 0
    var hostname : String = ""
}

func logNodeConnectionKey(key : UInt8){
    if key == NodeConnectionKey.pingResponse.rawValue {
        NSLog("Key:pingResponse")
    }else if key == NodeConnectionKey.nodeInfoResponse.rawValue{
        NSLog("Key:nodeInfoResponse")
    }else if key == NodeConnectionKey.ipResponse.rawValue{
        NSLog("Key:ipResponse")
    }else{
        NSLog("Unknown key:\(key)")
    }
}

func uint8ToString(char: UInt8) -> String{
    switch char {
    case 48:
        return "0"
    case 49:
        return "1"
    case 50:
        return "2"
    case 51:
        return "3"
    case 52:
        return "4"
    case 53:
        return "5"
    case 54:
        return "6"
    case 55:
        return "7"
    case 56:
        return "8"
    case 57:
        return "9"
    case 65:
        return "A"
    case 66:
        return "B"
    case 67:
        return "C"
    case 68:
        return "D"
    case 69:
        return "E"
    case 70:
        return "F"
    case 71:
        return "G"
    case 72:
        return "H"
    case 73:
        return "I"
    case 74:
        return "J"
    case 75:
        return "K"
    case 76:
        return "L"
    case 77:
        return "M"
    case 78:
        return "N"
    case 79:
        return "O"
    case 80:
        return "P"
    case 81:
        return "Q"
    case 82:
        return "R"
    case 83:
        return "S"
    case 84:
        return "T"
    case 85:
        return "U"
    case 86:
        return "V"
    case 87:
        return "W"
    case 88:
        return "X"
    case 89:
        return "Y"
    case 90:
        return "Z"
    case 97:
        return "a"
    case 98:
        return "b"
    case 99:
        return "c"
    case 100:
        return "d"
    case 101:
        return "e"
    case 102:
        return "f"
    case 103:
        return "g"
    case 104:
        return "h"
    case 105:
        return "i"
    case 106:
        return "k"
    case 107:
        return "k"
    case 108:
        return "l"
    case 109:
        return "m"
    case 110:
        return "n"
    case 111:
        return "o"
    case 112:
        return "p"
    case 113:
        return "q"
    case 114:
        return "r"
    case 115:
        return "s"
    case 116:
        return "t"
    case 117:
        return "u"
    case 118:
        return "v"
    case 119:
        return "w"
    case 120:
        return "x"
    case 121:
        return "y"
    case 122:
        return "z"
    default:
        return ""
    }
}


//                    if rcvDataString.contains("HOST-NAME"){
//                        // get host name
//                        DispatchQueue.main.async {
//                            self.nodeConnectionParameter.state = ServiceState.ready
//                            self.nodeConnectionParameter.hostName = String(rcvDataString.dropFirst("HOST-NAME".count))
//                            self.send(item: "GET-NODE-PARAM")
//                        }
//                    }
//
//                    if rcvDataString.contains("NODE-NAME"){
//                        // get node name
//                        DispatchQueue.main.async {
//                            self.nodeConnectionParameter.state = ServiceState.ready
//                            self.nodeConnectionParameter.nodeName = String(rcvDataString.dropFirst("NODE-NAME".count))
//                        }
//                    }

//while(self.nodeConnector?.state != NWConnection.State.ready){} //dead lock ??
//self.send(item: "GET-HOST-NAME")


//    private func send(item : String){
//        if(self.nodeConnector?.state != NWConnection.State.ready){
//            NSLog("speaker state is not ready")
//            return
//        }
//        var sendData = item.data(using: .utf8)!
//        var testdata = GamepadJoysticValue()
//        testdata.x = 12.1
//        testdata.y = 0.124
//        testdata.thumbstickButton = false
//        sendData = Data(bytes: &testdata, count: MemoryLayout<GamepadJoysticValue>.size) + sendData
//        self.nodeConnector!.send(content: sendData,
//                           completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
//            if (NWError != nil) {
//                NSLog("ROSC:Send:NWError:\(NWError!)")
//            }
//        })))
//    }
