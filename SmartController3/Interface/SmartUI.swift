//
//  ROSView.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/08/20.
//

import SwiftUI

struct SmartUI: View {
    @ObservedObject var ROSConnectHandler : ROSConnect
    @ObservedObject var GCC : GameControllerClass
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
                .gesture(DragGesture()
                            .onEnded({ value in
                                if (value.translation.width < 0 ) {
                                    // swiped to left
                                    NSLog("swipe to left")
                                    if(GCC.s1Slider > 0){
                                        GCC.s1Slider -= 1
                                    }
                                } else if (value.translation.width > 0 ) {
                                    // swiped to right
                                    NSLog("swipe to right")
                                    GCC.s1Slider += 1
                                }
                            }))
            
            VStack{
                HStack{
                    Button(action: {}, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("\(ROSConnectHandler.log4ROSC.customButtonLabel1)")
                                .foregroundColor(.white)
                                .bold()
                                .font(.title3)
                        }
                    }).simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{_ in
                                GCC.c1Button = true
                            }
                            .onEnded{_ in
                                GCC.c1Button = false
                            }
                    )
                    
                    
                    
                    Button(action: {}, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("\(ROSConnectHandler.log4ROSC.customButtonLabel2)")
                                .foregroundColor(.white)
                                .bold()
                                .font(.title3)
                        }
                    }).simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{_ in
                                GCC.c2Button = true
                            }
                            .onEnded{_ in
                                GCC.c2Button = false
                            }
                    )
                }
                
                Spacer()
                Slider(value: $GCC.s1Slider ,in: 0...100 , step: 1)
                Text("\(ROSConnectHandler.log4ROSC.customSliderLabel1):\(Int(GCC.s1Slider))")
                    .bold()
                    .font(.title3)
                    .padding(.top , 20)
                    .gesture(DragGesture()
                                .onEnded({ value in
                                    if (value.translation.width < 0 ) {
                                        // swiped to left
                                        NSLog("swipe to left")
                                        if(GCC.s1Slider > 0){
                                            GCC.s1Slider -= 1
                                        }
                                    } else if (value.translation.width > 0 ) {
                                        // swiped to right
                                        NSLog("swipe to right")
                                        GCC.s1Slider += 1
                                    }
                                }))
                
                Spacer()
            }
            .padding(.all)
        }
    }
}
