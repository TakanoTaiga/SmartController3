//
//  DeviceInforWidget.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import SwiftUI

struct DeviceInforWidget: View {
    @ObservedObject var GameControllerClass : GameControllerClass
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            if GameControllerClass.connected{
                HStack {
                    VStack {
                        if GameControllerClass.deviceName.contains("Xbox") {
                            CircleProgressView(progress: Double(GameControllerClass.battery)  , symbol: "logo.xbox")
                                .frame(width: UIScreen.main.bounds.height / 6, height: UIScreen.main.bounds.height / 6, alignment: .center)
                                .padding()
                        }else{
                            CircleProgressView(progress: Double(GameControllerClass.battery)  , symbol: "gamecontroller")
                                .frame(width: UIScreen.main.bounds.height / 6, height: UIScreen.main.bounds.height / 6, alignment: .center)
                                .padding()
                        }
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                HStack {
                    VStack {
                        Spacer()
                        Text("\(Int(GameControllerClass.battery * 100))%")
                            .fontWeight(.medium)
                            .font(.system(size: 40))
                            .padding(.all , 4)
                            .opacity(0.9)
                    }
                    .padding(.leading)
                    Spacer()
                }
            }else{
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            
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
