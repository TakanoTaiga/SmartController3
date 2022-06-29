//
//  GamePadClass.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import Foundation
import GameController
import SwiftUI

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
    
    
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: didConnectControllerHandler)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnectController)
        GCController.startWirelessControllerDiscovery{}
    }
    
    func didConnectControllerHandler(_ notification: Notification){
        self.connected = true
        let controller = notification.object as! GCController
        self.battery = controller.battery!.batteryLevel
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
    
    func didDisconnectController(_ notification: Notification){
        self.connected = false
        self.battery = -1
        self.deviceName = "N/A"
    }
    
    func stick(_ button: Int, _ xvalue: Float, _ yvalue: Float){
        if button == 1{
            leftJoystic[0] = xvalue
            leftJoystic[1] = yvalue
        }else if button == 2{
            rightJoystic[0] = xvalue
            rightJoystic[1] = yvalue
        }
    }
    
    func trigger(_ trigger: Int, _ value: Float){
        switch trigger{
        case 1:
            leftTrigger = value
        case 2:
            rightTrigger = value
        default:
            print("ERROR:GameControllerClass-trigger")
        }
    }
    
    func button(_ button: Int, _ pressed: Bool){
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
            print("ERROR:GameControllerClass-button")
        }
    }
}
