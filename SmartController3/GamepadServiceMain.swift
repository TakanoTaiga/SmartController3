//
//  GamepadServiceMain.swift.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

func triggerToGamepadValue(baseValue: inout GamepadValue, _ trigger: Int, value: Float){
    switch trigger{
    case 1:
        baseValue.leftTrigger.value = 2.0 * value - 1.0
        baseValue.leftTrigger.value *= -1
    case 2:
        baseValue.rightTrigger.value = 2.0 * value - 1.0
        baseValue.rightTrigger.value *= -1
    default: break
    }
}

func buttonToGamepadValue(baseValue: inout GamepadValue, _ button: Int, pressed: Bool){
    switch button {
    case 0:
        baseValue.dpad.left = pressed
    case 1:
        baseValue.dpad.up = pressed
    case 2:
        baseValue.dpad.right = pressed
    case 3:
        baseValue.dpad.down = pressed
    case 4:
        baseValue.button.x = pressed
    case 5:
        baseValue.button.y = pressed
    case 6:
        baseValue.button.b = pressed
    case 7:
        baseValue.button.a = pressed
    case 10:
        baseValue.leftJoystic.thumbstickButton = pressed
    case 11:
        baseValue.rightJoystic.thumbstickButton = pressed
    case 12:
        baseValue.leftShoulderButton = pressed
    case 13:
        baseValue.rightShoulderButton = pressed
    case 14:
        baseValue.leftTrigger.button = pressed
    case 15:
        baseValue.rightTrigger.button = pressed
        
    default: break
    }
}

func stickToGamepadValue(baseValue: inout GamepadValue, _ button: Int,  _ xvalue: Float, _ yvalue: Float){
    if button == 1{
        baseValue.leftJoystic.x = xvalue
        baseValue.leftJoystic.y = yvalue
    }else if button == 2{
        baseValue.rightJoystic.x = xvalue
        baseValue.rightJoystic.y = yvalue
    }
}
