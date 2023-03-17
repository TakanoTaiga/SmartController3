//
//  ROSView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/08/20.
//

import SwiftUI

struct SmartUI: View {
    @ObservedObject var ROSConnectHandler : NodeConnection
    @ObservedObject var GCC : GameControllerClass
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.brown)
                .opacity(0.1)
            
            VStack{
                HStack{
                    Button(action: {}, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text(ROSConnectHandler.smartUILabel.buttonA)
                                .foregroundColor(.white)
                                .bold()
                                .font(.title3)
                        }
                    }).simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{_ in
                                GCC.smartUIValue.buttonA = true
                            }
                            .onEnded{_ in
                                GCC.smartUIValue.buttonA = false
                            }
                    )
                    
                    
                    Button(action: {}, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text(ROSConnectHandler.smartUILabel.buttonB)
                                .foregroundColor(.white)
                                .bold()
                                .font(.title3)
                        }
                    }).simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{_ in
                                GCC.smartUIValue.buttonB = true
                            }
                            .onEnded{_ in
                                GCC.smartUIValue.buttonB = false
                            }
                    )
                }
                
                Spacer()
                Slider(value: $GCC.smartUIValue.slider ,in: 0...100 , step: 0.1)
                Text(ROSConnectHandler.smartUILabel.slider + String(format: ":%.1f", GCC.smartUIValue.slider))
                    .bold()
                    .font(.title3)
                    .padding(.top , 20)
                    .gesture(DragGesture()
                        .onEnded({ value in
                            if(abs(value.translation.width) > 150){
                                if (value.translation.width < 0 ) {
                                    // swiped to left
                                    if(GCC.smartUIValue.slider > 0){
                                        GCC.smartUIValue.slider -= 1
                                    }
                                } else if (value.translation.width > 0 ) {
                                    // swiped to right
                                    NSLog("swipe to right")
                                    GCC.smartUIValue.slider += 1
                                }
                            }else{
                                if (value.translation.width < 0 ) {
                                    // swiped to left
                                    if(GCC.smartUIValue.slider > 0){
                                        GCC.smartUIValue.slider -= 0.2
                                    }
                                } else if (value.translation.width > 0 ) {
                                    // swiped to right
                                    NSLog("swipe to right")
                                    GCC.smartUIValue.slider += 0.2
                                }
                            }
                        }))
                
                Spacer()
            }
            .padding(.all)
        }
    }
}
