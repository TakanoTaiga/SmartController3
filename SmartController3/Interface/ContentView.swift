//
//  ContentView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var nodeConnectionClassObject = NodeConnection()
    
    @State private var show_settings = false
    @State private var show_systeminfo = true
    @State private var show_slowmode = false
    @State private var show_big_slowmode = false
    
    @State private var press_gear = false
    
    @State private var need_longpress = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture {
                    show_settings = false
                }
            
            VStack {
                ZStack {
                    NodeStatus(nodeConnectionClassObject: nodeConnectionClassObject)
                        .padding(.horizontal)
                        .blur(radius: need_longpress ? 5 : 0.0)
                        .opacity(need_longpress ? 0.7 : 1.0)
                        .animation(.easeIn(duration: 0.1), value: need_longpress)
                    HStack{
                        Spacer()
                        
                        Text("長押ししてください")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .opacity(need_longpress ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.2), value: need_longpress)
                        
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .opacity(press_gear ? 0.5 : 1.0)
                    }
                }
                
                ScrollView(showsIndicators: false){
                    VStack{
                        if show_big_slowmode {
                            SlowMode(nodeConnectionClass: nodeConnectionClassObject)
                                .frame(height: 200)
                                .padding(.bottom)
                                .onAppear(){
                                    show_slowmode = false
                                }
                        }
                        
                        ControllerInfomationWidget(nodeConnectionClass: nodeConnectionClassObject)
                            .padding(.bottom)
                        
                        if show_systeminfo {
                            SystemInfo(NodeConnectionClassObject: nodeConnectionClassObject)
                                .frame(height: 200)
                                .padding(.bottom)
                        }
                        
                        if show_slowmode {
                            SlowMode(nodeConnectionClass: nodeConnectionClassObject)
                                .frame(height: 50)
                                .padding(.bottom)
                                .onAppear(){
                                    show_big_slowmode = false
                                }
                        }
                        
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            .ignoresSafeArea(edges: [.bottom])
            .onTapGesture {
                show_settings = false
            }
            
            VStack{
                Rectangle()
                    .frame(height: 90)
                    .ignoresSafeArea()
                    .opacity(0.0001)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.3)
                        .onEnded({ _ in
                            show_settings.toggle()
                            NSLog("press")
                        })
                        .onChanged({ _ in
                            press_gear = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                press_gear = false
                                if !show_settings {
                                    need_longpress = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    need_longpress = false
                                }
                            }
                            
                            if show_settings{
                                show_settings = false
                            }
                        })
                    )
                Spacer()
                
            }
            
            VStack{
                Spacer()
                ZStack {
                    Rectangle()
                        .foregroundStyle(.quaternary)
                        .background(.ultraThinMaterial)
                        .shadow(radius: 10)
                    
                    VStack{
                        HStack {
                            Text("設定")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Toggle("デバッグパネル", isOn: $show_systeminfo)
                        
                        Toggle("スローモード", isOn: $show_slowmode)
                        
                        Toggle("最大 スローモード", isOn: $show_big_slowmode)
                            

                        Spacer()
                    }.padding(.all)
                    
                }
                .frame(height: 300)
                .ignoresSafeArea()
                .offset(y: show_settings ? 100 : 600)
                .animation(.easeInOut(duration: 0.2), value: show_settings)
            }
        }
    }
}
