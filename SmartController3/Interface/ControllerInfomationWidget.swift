//
//  ControllerInfomationWidget.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI

struct ControllerInfomationWidget: View {
    @ObservedObject var GameController : GameControllerClass
    
    var body: some View {
        if GameController.info.connected {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.brown)
                    .opacity(0.1)
                
                HStack {
                    VStack {
                        if GameController.gamepadValue.leftJoystic.x != 0{
                            JoyStick(GameController: GameController , LR: true)
                                .rotationEffect(Angle(degrees: Double(atan_custom(x: GameController.gamepadValue.leftJoystic.x,
                                                                                  y: GameController.gamepadValue.leftJoystic.y))))
                                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        }else{
                            if GameController.gamepadValue.leftJoystic.thumbstickButton {
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
                        
                        if GameController.gamepadValue.rightJoystic.x != 0{
                            JoyStick(GameController: GameController , LR: false)
                                .rotationEffect(Angle(degrees: Double(atan_custom(x: GameController.gamepadValue.rightJoystic.x,
                                                                                  y: GameController.gamepadValue.rightJoystic.y))))
                                .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
                        }else{
                            if GameController.gamepadValue.rightJoystic.thumbstickButton {
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
                        if GameController.info.deviceName.contains("Xbox") {
                            CircleProgressView(progress: Double(GameController.info.battery) , symbol: "logo.xbox")
                                .frame(width: UIScreen.main.bounds.height / 6,
                                       height: UIScreen.main.bounds.height / 6,
                                       alignment: .center)
                        }else{
                            CircleProgressView(progress: Double(GameController.info.battery) , symbol: "gamecontroller")
                                .frame(width: UIScreen.main.bounds.height / 6,
                                       height: UIScreen.main.bounds.height / 6,
                                       alignment: .center)
                        }
                        
                        ZStack {
                            Circle()
                                .frame(width: 70, height: 70, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            
                            Image(systemName: "circle.grid.cross")
                                .foregroundColor(.white)
                                .font(.title)
                            
                            if GameController.gamepadValue.button.y{
                                Image(systemName: "circle.grid.cross.up.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.gamepadValue.button.x{
                                Image(systemName: "circle.grid.cross.left.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.gamepadValue.button.a{
                                Image(systemName: "circle.grid.cross.down.filled")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            if GameController.gamepadValue.button.b{
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
                    .foregroundColor(.brown)
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
                if GameController.gamepadValue.leftJoystic.thumbstickButton{
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
                if GameController.gamepadValue.rightJoystic.thumbstickButton{
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
            return sqrt(GameController.gamepadValue.leftJoystic.x * GameController.gamepadValue.leftJoystic.x + GameController.gamepadValue.leftJoystic.y * GameController.gamepadValue.leftJoystic.y) * -20.0
        }else{
            return sqrt(GameController.gamepadValue.rightJoystic.x * GameController.gamepadValue.rightJoystic.x + GameController.gamepadValue.rightJoystic.y * GameController.gamepadValue.rightJoystic.y) * -20.0
        }
    }
}


struct CircleProgressView: View {
    var progress: Double
    let symbol : String
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(.gray, lineWidth: 7)
                    .opacity(0.2)
                
                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0))) // 線の長さを指定
                        .stroke(.green, style: StrokeStyle(lineWidth: 7,lineCap: .round))
                        .rotationEffect(.degrees(-90.0)) // 線を上から開始させる
                }else{
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress * -1, 1.0))) // 線の長さを指定
                        .stroke(.green, style: StrokeStyle(lineWidth: 7,lineCap: .round))
                        .rotationEffect(.degrees(360.0 * progress - 90.0)) // 線を上から開始させる
                }
                
                Image(systemName: symbol)
                    .foregroundColor(.gray)
                    .font(.title)
            }
        }
    }
}
