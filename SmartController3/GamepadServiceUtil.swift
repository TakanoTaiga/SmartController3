//
//  GamepadServiceUtil.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/03/08.
//

import Foundation

struct GamepadInfoValue{
    var connected : Bool = false
    var battery : Float32 = 0
    var deviceName : String = ""
}

struct GamepadJoysticValue{
    var x : Float32 = 0
    var y : Float32 = 0
    var thumbstickButton : Bool = false
}

struct GamepadTriggerValue{
    var value : Float32 = 0
    var button : Bool = false
}

struct GamepadDpadValue{
    var up : Bool = false
    var down : Bool = false
    var left : Bool = false
    var right : Bool = false
}

struct GamepadButtonValue{
    var x : Bool = false
    var y : Bool = false
    var a : Bool = false
    var b : Bool = false
}

struct GamepadButtonValue2x{
    var x : Bool = false
    var y : Bool = false
    var a : Bool = false
}

struct GamepadValue{    
    var leftJoystic =  GamepadJoysticValue()
    var rightJoystic =  GamepadJoysticValue()
    
    var leftTrigger = GamepadTriggerValue()
    var rightTrigger = GamepadTriggerValue()
    
    var spacer = GamepadButtonValue2x()
    
    var dpad = GamepadDpadValue()
    var button = GamepadButtonValue()
    
    var leftShoulderButton = false
    var rightShoulderButton = false
}
