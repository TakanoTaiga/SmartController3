//
//  GamepadServiceMain.swift.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import GameController
import Network

class GameControllerClass : ObservableObject{
    @Published private (set) public var gamepadValue = GamepadValue()
    @Published private (set) public var info = GamepadInfoValue()
    @Published var smartUIValue = SmartUIValue()
    
    
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
        if button == 1{
            gamepadValue.leftJoystic.x = xvalue
            gamepadValue.leftJoystic.y = yvalue
        }else if button == 2{
            gamepadValue.rightJoystic.x = xvalue
            gamepadValue.rightJoystic.y = yvalue
        }
    }
    
    private func trigger(_ trigger: Int, _ value: Float){
        switch trigger{
        case 1:
            gamepadValue.leftTrigger.value = 2.0 * value - 1.0
            gamepadValue.leftTrigger.value *= -1
        case 2:
            gamepadValue.rightTrigger.value = 2.0 * value - 1.0
            gamepadValue.rightTrigger.value *= -1
        default:
            NSLog("ERROR:GameControllerClass-trigger")
        }
    }
    
    private func button(_ button: Int, _ pressed: Bool){
        switch button {
        case 0:
            gamepadValue.dpad.left = pressed
        case 1:
            gamepadValue.dpad.up = pressed
        case 2:
            gamepadValue.dpad.right = pressed
        case 3:
            gamepadValue.dpad.down = pressed
        case 4:
            gamepadValue.button.x = pressed
        case 5:
            gamepadValue.button.y = pressed
        case 6:
            gamepadValue.button.b = pressed
        case 7:
            gamepadValue.button.a = pressed
        case 10:
            gamepadValue.leftJoystic.thumbstickButton = pressed
        case 11:
            gamepadValue.rightJoystic.thumbstickButton = pressed
        case 12:
            gamepadValue.leftShoulderButton = pressed
        case 13:
            gamepadValue.rightShoulderButton = pressed
        case 14:
            gamepadValue.leftTrigger.button = pressed
        case 15:
            gamepadValue.rightTrigger.button = pressed
            
        default:
            NSLog("ERROR:GameControllerClass-button")
        }
        
        self.sendGameControllerStatus()
    }
    
    //Network Connections
    
    private var speaker : NWConnection?
    private let udpSendQueue = DispatchQueue(label: "udpSendQueue" , qos: .utility , attributes: .concurrent)
    
    public func NWSetup(host: NWEndpoint.Host?){
        if let host = host {
            self.speaker = NWConnection(host: host, port: 64201, using: .udp)
            self.speaker!.start(queue: udpSendQueue)
        }
    }

    public func sendGameControllerStatus(){
        if(speaker?.state != NWConnection.State.ready){return}
        
        var sendItem = GamepadResponseData()
        sendItem.header = NodeConnectionKey.gamepadValueRequest.rawValue
        sendItem.gamepadData = gamepadValue
        sendItem.smartUIData = smartUIValue
        let sendData = Data(bytes: &sendItem, count: MemoryLayout<GamepadResponseData>.size)
        
        self.speaker!.send(content: sendData, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError != nil) {
                print("GCC:Send:NWError:\(NWError!)")
            }
        })))
    }
    
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectControllerHandler)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
}
