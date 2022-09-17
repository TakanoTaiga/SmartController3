//
//  ControllerInfomationWidget.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import SwiftUI

struct ControllerInfomationWidget: View {
    @ObservedObject var GameController : GameControllerClass
    
    var body: some View {
        if GameController.connected {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                    .opacity(0.1)
                
                HStack {
                    VStack {
                        if GameController.leftJoystic[0] != 0{
                            JoyStick(GameController: GameController , LR: true)
                                .rotationEffect(Angle(degrees: Double(atan_custom(x: GameController.leftJoystic[0], y: GameController.leftJoystic[1]))))
                                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        }else{
                            if GameController.leftThumbstickButton {
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                    
                                    Image(systemName: "l.joystick.press.down.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                }
                            }else{
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                    
                                    Image(systemName: "l.joystick")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                }
                            }
                            
                        }

                        
                        if GameController.rightJoystic[0] != 0{
                            JoyStick(GameController: GameController , LR: false)
                                .rotationEffect(Angle(degrees: Double(atan_custom(x: GameController.rightJoystic[0], y: GameController.rightJoystic[1]))))
                                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        }else{
                            if GameController.rightThumbstickButton {
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                    
                                    Image(systemName: "r.joystick.press.down.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                }
                            }else{
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70, alignment: .center)
                                        .foregroundColor(.black)
                                        .opacity(0.5)
                                    
                                    Image(systemName: "r.joystick")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                }
                            }
                        }
                    }
                    
                    VStack{
                        if GameController.deviceName.contains("Xbox") {
                            CircleProgressView(progress: Double(GameController.battery)  , symbol: "logo.xbox")
                                .frame(width: UIScreen.main.bounds.height / 6, height: UIScreen.main.bounds.height / 6, alignment: .center)
                                //.padding()
                        }else{
                            CircleProgressView(progress: Double(GameController.battery)  , symbol: "gamecontroller")
                                .frame(width: UIScreen.main.bounds.height / 6, height: UIScreen.main.bounds.height / 6, alignment: .center)
                                //.padding()
                        }
                        
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            
                            Image(systemName: "circle.grid.cross")
                                .foregroundColor(.white)
                                .font(.title)
                            
                            if GameController.buttonY{
                                Image(systemName: "circle.grid.cross.up.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.buttonX{
                                Image(systemName: "circle.grid.cross.left.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.buttonA{
                                Image(systemName: "circle.grid.cross.down.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.buttonB{
                                Image(systemName: "circle.grid.cross.right.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            
                            
                        }
                        
                    }
                }
                
            }
        }else{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                    .opacity(0.1)
                ProgressView()
                    .scaleEffect(1.5)
            }
           
        }
        
    }
    
    func atan_custom(x : Float , y : Float) -> Float{
        let angle_s = atan(sqrt(y * y) / sqrt(x * x)) * (180 / 3.141592)
        
        if x > 0.0 && y > 0.0 {
            return angle_s
        }else if x < 0.0 && y > 0.0{
            return (90 - angle_s) + 90
        }else if x < 0.0 && y < 0.0{
            return angle_s + 180
        }else{
            return (90 - angle_s) + 270
        }
    }
}

struct JoyStick: View {
    @ObservedObject var GameController : GameControllerClass
    @State var LR : Bool
    
    var body: some View{
        ZStack {
            Circle()
                .frame(width: 70, height: 70, alignment: .center)
                .foregroundColor(.black)
                .opacity(0.5)
            
            if LR{
                if GameController.leftThumbstickButton{
                    Image(systemName: "circle.circle.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                        .offset(x: CGFloat(powerResult(LR: true)))
                }else{
                    Image(systemName: "circle.circle")
                        .foregroundColor(.white)
                        .font(.caption)
                        .offset(x: CGFloat(powerResult(LR: true)))
                }
            }else{
                if GameController.rightThumbstickButton{
                    Image(systemName: "circle.circle.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                        .offset(x: CGFloat(powerResult(LR: false)))
                }else{
                    Image(systemName: "circle.circle")
                        .foregroundColor(.white)
                        .font(.caption)
                        .offset(x: CGFloat(powerResult(LR: false)))
                }
            }
            
            
        }
    }
    
    func powerResult(LR : Bool) -> Float{
        if LR{
            return sqrt(GameController.leftJoystic[0] * GameController.leftJoystic[0] + GameController.leftJoystic[1] * GameController.leftJoystic[1]) * -20.0
        }else{
            return sqrt(GameController.rightJoystic[0] * GameController.rightJoystic[0] + GameController.rightJoystic[1] * GameController.rightJoystic[1]) * -20.0
        }
    }
}
