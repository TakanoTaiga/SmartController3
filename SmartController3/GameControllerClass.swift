//
//  GamePadClass.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import GameController
import Network
struct infoValue{
    var connected : Bool
    var battery : Float
    var deviceName : String
}
struct joysticValue{
    var x : Float
    var y : Float
}
struct triggerValue{
    var value : Float
    var button : Bool
}
struct dpadValue{
    var up : Bool
    var down : Bool
    var left : Bool
    var right : Bool
}
struct buttonValue{
    var x : Bool
    var y : Bool
    var a : Bool
    var b : Bool
}
struct gamepadValue{
    var info : infoValue
    
    var leftJoystic : joysticValue
    var rightJoystic : joysticValue
    
    var leftTrigger : triggerValue
    var rightTrigger : triggerValue
    
    var dpad : dpadValue
    var button : buttonValue
    
    var leftThumbstickButton : Bool
    var rightThumbstickButton : Bool
    
    var leftShoulderButton : Bool
    var rightShoulderButton : Bool
}

class GameControllerClass : ObservableObject{
    @Published var gamepad = gamepadValue(
        info: infoValue(connected: false, battery: 0, deviceName: ""),
        leftJoystic: joysticValue(x: 0, y: 0),
        rightJoystic: joysticValue(x: 0, y: 0),
        leftTrigger: triggerValue(value: 0, button: false),
        rightTrigger: triggerValue(value: 0, button: false),
        dpad: dpadValue(up: false, down: false, left: false, right: false),
        button: buttonValue(x: false, y: false, a: false, b: false),
        leftThumbstickButton: false,
        rightThumbstickButton: false,
        leftShoulderButton: false,
        rightShoulderButton: false)
    
    @Published var c1Button : Bool = false
    @Published var c2Button : Bool = false
    @Published var s1Slider : Float = 0.0
    @Published var s2Slider : Float = 0.0
    
    @Published var debugData : String = ""
    
    private var sendingArray : [String] = ["","","","",""]
    
    @Published var counter = 0
    @Published var needUpdate = true;
    
    
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectControllerHandler)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
    
    private func didConnectControllerHandler(_ notification: Notification){
        gamepad.info.connected = true
        let controller = notification.object as! GCController
        if let battery = controller.battery{
            gamepad.info.battery = battery.batteryLevel
        }
        gamepad.info.deviceName = controller.productCategory
        
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
        gamepad.info.connected = false
        gamepad.info.battery = -1
        gamepad.info.deviceName = "N/A"
    }
    
    private func stick(_ button: Int, _ xvalue: Float, _ yvalue: Float){
        if button == 1{
            gamepad.leftJoystic.x = xvalue
            gamepad.leftJoystic.y = yvalue
        }else if button == 2{
            gamepad.rightJoystic.x = xvalue
            gamepad.rightJoystic.y = yvalue
        }
    }
    
    private func trigger(_ trigger: Int, _ value: Float){
        switch trigger{
        case 1:
            gamepad.leftTrigger.value = 2.0 * value - 1.0
            gamepad.leftTrigger.value *= -1
        case 2:
            gamepad.rightTrigger.value = 2.0 * value - 1.0
            gamepad.rightTrigger.value *= -1
        default:
            NSLog("ERROR:GameControllerClass-trigger")
        }
    }
    
    private func button(_ button: Int, _ pressed: Bool){
        switch button {
        case 0:
            gamepad.dpad.left = pressed
        case 1:
            gamepad.dpad.up = pressed
        case 2:
            gamepad.dpad.right = pressed
        case 3:
            gamepad.dpad.down = pressed
        case 4:
            gamepad.button.x = pressed
        case 5:
            gamepad.button.y = pressed
        case 6:
            gamepad.button.b = pressed
        case 7:
            gamepad.button.a = pressed
        case 10:
            gamepad.leftThumbstickButton = pressed
        case 11:
            gamepad.rightThumbstickButton = pressed
        case 12:
            gamepad.leftShoulderButton = pressed
        case 13:
            gamepad.rightShoulderButton = pressed
        case 14:
            gamepad.leftTrigger.button = pressed
        case 15:
            gamepad.rightTrigger.button = pressed
            
        default:
            NSLog("ERROR:GameControllerClass-button")
        }
        
        self.sendGameControllerStatus(force: false)
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
    
    private func checkOverlap(data:String)-> Bool{
        sendingArray[4] = sendingArray[3]
        sendingArray[3] = sendingArray[2]
        sendingArray[2] = sendingArray[1]
        sendingArray[1] = sendingArray[0]
        sendingArray[0] = data
        
        if(sendingArray[4] == sendingArray[3] &&
           sendingArray[3] == sendingArray[2] &&
           sendingArray[2] == sendingArray[1] &&
           sendingArray[1] == sendingArray[0]){
            return false
        }else{
            return true
        }
        
    }
    
    
    public func sendGameControllerStatus(force : Bool){
        var sendingItem : String = "GCINFO,"
        sendingItem += "J:" + String(gamepad.leftJoystic.x * -1) + ":" + String(gamepad.leftJoystic.x) + ","
        sendingItem += "T:" + String(gamepad.leftTrigger.value) + ","
        
        sendingItem += "J:" + String(gamepad.rightJoystic.x * -1) + ":" + String(gamepad.rightJoystic.x) + ","
        sendingItem += "T:" + String(gamepad.rightTrigger.value) + ","
        
        if(gamepad.dpad.left){
            sendingItem += "T:1,"
        }else if(gamepad.dpad.right){
            sendingItem += "T:-1,"
        }else{
            sendingItem += "T:0,"
        }
        
        if(gamepad.dpad.up){
            sendingItem += "T:1,"
        }else if(gamepad.dpad.down){
            sendingItem += "T:-1,"
        }else{
            sendingItem += "T:0,"
        }
        
        sendingItem += "B:" + self.Bool2String(bool: gamepad.button.a) + ","
        sendingItem += "B:" + self.Bool2String(bool: gamepad.button.b) + ","
        sendingItem += "B:" + self.Bool2String(bool: gamepad.button.x) + ","
        sendingItem += "B:" + self.Bool2String(bool: gamepad.button.y) + ","
        
        sendingItem += "B:" + self.Bool2String(bool: gamepad.leftShoulderButton) + ","
        sendingItem += "B:" + self.Bool2String(bool: gamepad.rightShoulderButton) + ","
        
        sendingItem += "B:" + self.Bool2String(bool: false) + ","
        sendingItem += "B:" + self.Bool2String(bool: false) + ","
        
        sendingItem += "B:0,"
        
        sendingItem += "B:" + self.Bool2String(bool: gamepad.leftThumbstickButton) + ","
        sendingItem += "B:" + self.Bool2String(bool: gamepad.rightThumbstickButton) + ","
        
        sendingItem += "B:0,"
        
        sendingItem += "C:" + self.Bool2String(bool: self.c1Button) + ","
        sendingItem += "C:" + self.Bool2String(bool: self.c2Button) + ","
        sendingItem += "S:" + String(self.s1Slider) + ","
        sendingItem += "S:" + String(self.s2Slider) + ","
        
        sendingItem += "END"
        
        if(force){
            self.send(item: sendingItem)
            self.counter += 1
            NSLog(sendingItem)
            return
        }
        
        if(checkOverlap(data: sendingItem)){
            self.send(item: sendingItem)
            self.counter += 1
            self.needUpdate = false
            NSLog(sendingItem)
        }
    }
}
