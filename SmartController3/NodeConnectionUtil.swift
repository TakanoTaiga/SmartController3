//
//  NodeConnectionUtil.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/03/08.
//

import Network
import SwiftUI

enum robot_state{
    case ready
    case ping_wait
    case failed
}

func convertDataToUInt16(data: Data) -> UInt16? {
    guard data.count == 2 else {
        return nil
    }

    return data.withUnsafeBytes { bytes in
        bytes.load(as: UInt16.self)
    }
}

func convertDataToFloat32(data: Data) -> Float32? {
    guard data.count == 4 else {
        return nil
    }

    return data.withUnsafeBytes { bytes in
        bytes.load(as: Float32.self)
    }
}


func convertDataToIpAddr(data: Data) -> format_of_ip_addr? {
    guard data.count == 4 else {
        return nil
    }
        
    return data.withUnsafeBytes { bytes in
        bytes.load(as: format_of_ip_addr.self)
    }
}

func convertGamepadValueToData(gamepadValue: GamepadValue) -> Data? {
    var toByteItem = gamepadValue
    return Data(bytes: &toByteItem, count: MemoryLayout<GamepadValue>.size)
}

func convertFloat32ToData(_ float: Float32) -> Data? {
    var toByteItem = float
    return Data(bytes: &toByteItem, count: MemoryLayout<Float32>.size)
}

func convertBoolToData(_ bool: Bool) -> Data? {
    var toByteItem = bool
    return Data(bytes: &toByteItem, count: MemoryLayout<Bool>.size)
}

func uint8ToString(char: UInt8) -> String {
    if (32...126).contains(char) {
        return String(Character(UnicodeScalar(char)))
    }
    return ""
}
