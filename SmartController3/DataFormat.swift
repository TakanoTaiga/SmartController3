//
//  DataFormat.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/07/01.
//

import Foundation

struct format_of_search_app {
    let header_id : UInt8
    let session_id : UInt8
    let ip_addr : format_of_ip_addr
    let ip_port : UInt16
    let robot_name : String
}

struct format_of_ping_request {
    let header_id : UInt8
    let session_id : UInt8
}

struct format_of_search_app_response {
    let header_id : UInt8
    let session_id : UInt8
}

struct format_of_search_ping_response {
    let header_id : UInt8
    let session_id : UInt8
}

struct format_of_gamepad_value {
    let header_id : UInt8
    let session_id : UInt8
}

enum header_id_list: UInt8{
    case search_app = 0xC9
    case ping_request = 0xCA
    case search_app_response = 0xCB
    case search_ping_response = 0xCC
    case gamepad_value = 0xCD
    case unknown = 0
}


struct format_of_ip_addr{
    let o_1 : UInt8
    let o_2 : UInt8
    let o_3 : UInt8
    let o_4 : UInt8
}
