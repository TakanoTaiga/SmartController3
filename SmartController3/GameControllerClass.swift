//
//  GamePadClass.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import GameController
import Network

class GameControllerClass : ObservableObject{
    @Published var connected = false
    @Published var battery : Float = 0
    @Published var deviceName : String = ""
    
    @Published var leftJoystic : [Float] = [0,0]
    @Published var rightJoystic : [Float] = [0,0]
    
    @Published var leftTrigger : Float = 0
    @Published var rightTrigger : Float = 0
    
    @Published var dpadLeft : Bool = false
    @Published var dpadUp : Bool = false
    @Published var dpadRight : Bool = false
    @Published var dpadDown : Bool = false
    
    @Published var buttonX : Bool = false
    @Published var buttonY : Bool = false
    @Published var buttonB : Bool = false
    @Published var buttonA : Bool = false
    
    @Published var leftThumbstickButton : Bool = false
    @Published var rightThumbstickButton : Bool = false
    
    @Published var optionButton :Bool = false
    @Published var menuButton : Bool = false
    
    @Published var leftShoulderButton : Bool = false
    @Published var rightShoulderButton : Bool = false
    
    @Published var leftTriggerButton : Bool = false
    @Published var rightTriggerButton : Bool = false
    
    @Published var debugData : String = ""
    
    
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectControllerHandler)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
    
    private func didConnectControllerHandler(_ notification: Notification){
        self.connected = true
        let controller = notification.object as! GCController
        if let battery = controller.battery{
            self.battery = battery.batteryLevel
        }
        self.deviceName = controller.productCategory
        
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
        
        controller.extendedGamepad?.buttonOptions?.pressedChangedHandler = { (button, value, pressed) in self.button(8, pressed) }
        controller.extendedGamepad?.buttonMenu.pressedChangedHandler = { (button, value, pressed) in self.button(9, pressed) }
        controller.extendedGamepad?.leftThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(10, pressed) }
        controller.extendedGamepad?.rightThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(11, pressed) }
        
        controller.extendedGamepad?.leftThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(10, pressed) }
        controller.extendedGamepad?.rightThumbstickButton?.pressedChangedHandler = { (button, value, pressed) in self.button(11, pressed) }
        
        controller.extendedGamepad?.leftShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(12, pressed) }
        controller.extendedGamepad?.rightShoulder.pressedChangedHandler = { (button, value, pressed) in self.button(13, pressed) }
        controller.extendedGamepad?.leftTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(14, pressed) }
        controller.extendedGamepad?.rightTrigger.pressedChangedHandler = { (button, value, pressed) in self.button(15, pressed) }
        
    }
    
    private func didDisconnectController(_ notification: Notification){
        self.connected = false
        self.battery = -1
        self.deviceName = "N/A"
    }
    
    private func stick(_ button: Int, _ xvalue: Float, _ yvalue: Float){
        if button == 1{
            leftJoystic[0] = xvalue
            leftJoystic[1] = yvalue
        }else if button == 2{
            rightJoystic[0] = xvalue
            rightJoystic[1] = yvalue
        }
    }
    
    private func trigger(_ trigger: Int, _ value: Float){
        switch trigger{
        case 1:
            leftTrigger = value
        case 2:
            rightTrigger = value
        default:
            NSLog("ERROR:GameControllerClass-trigger")
        }
    }
    
    private func button(_ button: Int, _ pressed: Bool){
        switch button {
        case 0:
            dpadLeft = pressed
        case 1:
            dpadUp = pressed
        case 2:
            dpadRight = pressed
        case 3:
            dpadDown = pressed
        case 4:
            buttonX = pressed
        case 5:
            buttonY = pressed
        case 6:
            buttonB = pressed
        case 7:
            buttonA = pressed
        case 8:
            optionButton = pressed
        case 9:
            menuButton = pressed
        case 10:
            leftThumbstickButton = pressed
        case 11:
            rightThumbstickButton = pressed
        case 12:
            leftShoulderButton = pressed
        case 13:
            rightShoulderButton = pressed
        case 14:
            leftTriggerButton = pressed
        case 15:
            rightTriggerButton = pressed
            
        default:
            NSLog("ERROR:GameControllerClass-button")
        }
        
        self.sendGameControllerStatus()
    }
    
    //Network Connections
    
    private var speaker : NWConnection?
    private let udpSendQueue = DispatchQueue(label: "udpSendQueue" , qos: .utility , attributes: .concurrent)
    private var readyForNWConnection = false
    
    private func send(item : String){
        if !readyForNWConnection{return}
        
        let payload = item.data(using: .utf8)!
        self.speaker!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("GCC:Send:Data was sent to UDP")
            } else {
                print("GCC:Send:NWError:\(NWError!)")
            }
        })))
        self.debugData = item
    }
    
    private func Bool2String(bool : Bool)-> String {
        if bool{
            return "1"
        }else{
            return "0"
        }
    }
    
    public func NWSetup(host: NWEndpoint.Host?){
        if let host = host {
            self.speaker = NWConnection(host: host, port: 64201, using: .udp)
            self.speaker!.start(queue: udpSendQueue)
            self.readyForNWConnection = true
        }
    }
    
    public func sendGameControllerStatus(){
        var sendingItem : String = "GCINFO,"
        sendingItem += "1:" + String(self.leftJoystic[0]) + ":" + String(self.leftJoystic[1]) + ","
        sendingItem += "2:" + String(self.rightJoystic[0]) + ":" + String(self.rightJoystic[1]) + ","
        
        sendingItem += "3:" + String(self.leftTrigger) + ","
        sendingItem += "4:" + String(self.rightTrigger) + ","
        
        sendingItem += "5:" + self.Bool2String(bool: self.dpadLeft) + ","
        sendingItem += "6:" + self.Bool2String(bool: self.dpadUp) + ","
        sendingItem += "7:" + self.Bool2String(bool: self.dpadRight) + ","
        sendingItem += "8:" + self.Bool2String(bool: self.dpadDown) + ","
        
        sendingItem += "9:" + self.Bool2String(bool: self.buttonX) + ","
        sendingItem += "A:" + self.Bool2String(bool: self.buttonY) + ","
        sendingItem += "B:" + self.Bool2String(bool: self.buttonB) + ","
        sendingItem += "C:" + self.Bool2String(bool: self.buttonA) + ","
        
        sendingItem += "D:" + self.Bool2String(bool: self.leftThumbstickButton) + ","
        sendingItem += "E:" + self.Bool2String(bool: self.rightThumbstickButton) + ","
        
        sendingItem += "F:" + self.Bool2String(bool: self.optionButton) + ","
        sendingItem += "G:" + self.Bool2String(bool: self.menuButton) + ","
        
        sendingItem += "H:" + self.Bool2String(bool: self.leftShoulderButton) + ","
        sendingItem += "I:" + self.Bool2String(bool: self.rightShoulderButton) + ","
        
        sendingItem += "J:" + self.Bool2String(bool: self.leftTriggerButton) + ","
        sendingItem += "K:" + self.Bool2String(bool: self.rightTriggerButton) + ",END"
        
        self.send(item: sendingItem)
    }
}
