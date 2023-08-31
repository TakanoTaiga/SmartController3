//
//  NodeConnectionMain.swift
//  SmartController3
//
//  Created by Taiga Takano on 2021/08/14.
//

import Network
import CoreTelephony
import GameController

class NodeConnection : ObservableObject{
    @Published private (set) public var name : String = ""
    @Published private (set) public var state : robot_state = .failed
    @Published private (set) public var consoleOut : [String] = ["System Start"]
    @Published private (set) public var gamepadValue = GamepadValue()
    @Published private (set) public var info = GamepadInfoValue()
    @Published var smartUIValue = SmartUIValue()
    
    private var app_talker : NWConnection?
    private var listener = try! NWListener(using: .udp, on: 64202)
    private let queue = DispatchQueue(label: "UDPQueue" , qos: .userInteractive , attributes: .concurrent)
    
    
    public func send_data(item: Data){
        guard let connection = app_talker, connection.state == .ready else {
            nc_info("app_talker", "is not ready")
            return
        }
        
        connection.send(content: item, completion: NWConnection.SendCompletion.contentProcessed { error in
            if let error = error {
                self.nc_info("app_talker", "\(error)")
            }
        })
    }
    
    
    private func nc_info(_ header: String , _ data: String , only_nslog: Bool = false){
        let log = "[\(header)]: \(data)"
         NSLog(log)
        
        if only_nslog {return}
        
        consoleOut.append(log)
         if consoleOut.count > 20 {
             consoleOut.removeFirst()
         }
    }
    
    private func callback_search_app(packet_data: Data){
        guard packet_data.count >= 24 else {
            self.nc_info("ERROR" , "packet_data.count < 24")
            return
        }
        // desilizalize
        guard let ip_addr = convertDataToIpAddr(data: packet_data[2...5]) else {
            self.nc_info("ERROR" , " ip port desilizalize error")
            return
        }
        guard let ip_port = convertDataToUInt16(data: packet_data[6...7]) else {
            self.nc_info("ERROR" , " ip port desilizalize error")
            return
        }
        guard let robot_name = String(data: packet_data[8...23], encoding: .utf8) else {
            self.nc_info("ERROR" , "robot name desilizalize error")
            return
        }
        
        let responseData = format_of_search_app(header_id: packet_data[0], session_id: packet_data[1], ip_addr: ip_addr, ip_port: ip_port, robot_name: robot_name)
        self.nc_info("callback_search_app" , "response data: \(responseData)" , only_nslog: true)
        
        let ip = NWEndpoint.Host("\(responseData.ip_addr.o_1).\(responseData.ip_addr.o_2).\(responseData.ip_addr.o_3).\(responseData.ip_addr.o_4)")
        
        // setup app_talker
        self.app_talker = NWConnection(host: ip,
                                       port: NWEndpoint.Port(rawValue: responseData.ip_port) ?? 64201,
                                       using: .udp)
        self.app_talker?.start(queue: self.queue)
        
        while self.app_talker?.state != .ready {} //deadlock
        self.nc_info("app_talker" , "\(String(describing: self.app_talker?.state))")
        
        // cretae packet
        let item = Data([0xCB,0])
        self.send_data(item: item)
        
        self.name = responseData.robot_name
        self.state = robot_state.ready
    }
    
    private func callback_ping_request(packet_data: Data){
        if packet_data.count < 2 {
            self.nc_info("" , "packet_data.count < 2")
            return
        }
        let responseData =
        format_of_ping_request(header_id: packet_data[0],
                               session_id: packet_data[1])
        self.nc_info("callback_ping_request" , "\(responseData)")
        
        let item = Data([0xCC,0])
        self.send_data(item: item)
    }
    
    private func didConnectControllerHandler(_ notification: Notification){
        info.connected = true
        let controller = notification.object as! GCController
        if let battery = controller.battery{
            info.battery = battery.batteryLevel
        }
        info.deviceName = controller.productCategory
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { (button, xvalue, yvalue) in self.stick(1, xvalue, yvalue) }
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { (button, xvalue, yvalue) in self.stick(2, xvalue, yvalue) }
        
        controller.extendedGamepad?.leftTrigger.valueChangedHandler = { (button, value, pressed) in self.trigger(1, value) }
        controller.extendedGamepad?.rightTrigger.valueChangedHandler = { (button, value, pressed) in self.trigger(2, value) }
        
        controller.extendedGamepad?.dpad.left.pressedChangedHandler = { (button, value, pressed) in self.button(0, pressed) }
        controller.extendedGamepad?.dpad.up.pressedChangedHandler = { (button, value, pressed) in self.button(1, pressed) }
        controller.extendedGamepad?.dpad.right.pressedChangedHandler = { (button, value, pressed) in self.button(2, pressed) }
        controller.extendedGamepad?.dpad.down.pressedChangedHandler = { (button, value, pressed) in self.button(3, pressed) }
        
        controller.extendedGamepad?.buttonX.pressedChangedHandler = { (button, value, pressed) in self.button(4, pressed) }
        controller.extendedGamepad?.buttonY.pressedChangedHandler = { (button, value, pressed) in self.button(5, pressed) }
        controller.extendedGamepad?.buttonB.pressedChangedHandler = { (button, value, pressed) in self.button(6, pressed) }
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { (button, value, pressed) in self.button(7, pressed) }

        controller.extendedGamepad?.leftThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(10, pressed) }
        controller.extendedGamepad?.rightThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(11, pressed) }
        
        controller.extendedGamepad?.leftShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(12, pressed) }
        controller.extendedGamepad?.rightShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(13, pressed) }
        controller.extendedGamepad?.leftTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(14, pressed) }
        controller.extendedGamepad?.rightTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(15, pressed) }
        
    }
    
    private func didDisconnectController(_ notification: Notification){
        info.connected = false
        info.battery = -1
        info.deviceName = "N/A"
    }
    
    private func stick(_ button: Int, _ xvalue: Float, _ yvalue: Float){
        stickToGamepadValue(baseValue: &gamepadValue, button, xvalue, yvalue)
    }
    
    private func trigger(_ trigger: Int, _ value: Float){
        triggerToGamepadValue(baseValue: &gamepadValue, trigger, value: value)
    }
    
    private func button(_ button: Int, _ pressed: Bool){
        buttonToGamepadValue(baseValue: &gamepadValue, button, pressed: pressed)
        self.sendGameControllerStatus()
    }
    
    public func sendGameControllerStatus(){
        if(app_talker?.state != .ready){return}
        
        let connectionKey = Data([0xCD])
        let header = Data([0x80])
        var sendData = connectionKey + header 
        
        sendData += convertFloat32ToData(gamepadValue.leftJoystic.x)!
        sendData += convertFloat32ToData(gamepadValue.leftJoystic.y)!
        sendData += convertBoolToData(gamepadValue.leftJoystic.thumbstickButton)!
        
        sendData += convertFloat32ToData(gamepadValue.rightJoystic.x)!
        sendData += convertFloat32ToData(gamepadValue.rightJoystic.y)!
        sendData += convertBoolToData(gamepadValue.rightJoystic.thumbstickButton)!
        
        sendData += convertFloat32ToData(gamepadValue.leftTrigger.value)!
        sendData += convertBoolToData(gamepadValue.leftTrigger.button)!
        
        sendData += convertFloat32ToData(gamepadValue.rightTrigger.value)!
        sendData += convertBoolToData(gamepadValue.rightTrigger.button)!
        
        sendData += convertBoolToData(gamepadValue.dpad.up)!
        sendData += convertBoolToData(gamepadValue.dpad.down)!
        sendData += convertBoolToData(gamepadValue.dpad.left)!
        sendData += convertBoolToData(gamepadValue.dpad.right)!
        
        sendData += convertBoolToData(gamepadValue.button.x)!
        sendData += convertBoolToData(gamepadValue.button.y)!
        sendData += convertBoolToData(gamepadValue.button.a)!
        sendData += convertBoolToData(gamepadValue.button.b)!
        
        sendData += convertBoolToData(gamepadValue.leftShoulderButton)!
        sendData += convertBoolToData(gamepadValue.rightShoulderButton)!
        
        
        self.app_talker!.send(content: sendData, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError != nil) {
                DispatchQueue.main.async{
                    self.nc_info("sendGameControllerStatus" , "\(NWError!)")
                }
            }
        })))
    }

    
    init(){
        self.listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.queue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    DispatchQueue.main.async{
                        let header_id = data[0]
                        
                        self.nc_info("receive" , "\(header_id)")
                        
                        if(header_id == header_id_list.search_app.rawValue){
                            self.callback_search_app(packet_data: data)
                        }else if (header_id == header_id_list.ping_request.rawValue){
                            self.callback_ping_request(packet_data: data)
                        }
                    }
                }
                newConnection.cancel()
            })
        }
        self.listener.start(queue: self.queue)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectControllerHandler)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
}