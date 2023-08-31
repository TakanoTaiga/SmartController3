//
//  ContentView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var nodeConnectionClassObject = NodeConnection()
    
    @State private var flag = true
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                NodeStatus(nodeConnectionClassObject: nodeConnectionClassObject)
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false){
                    VStack{
                        ControllerInfomationWidget(nodeConnectionClass: nodeConnectionClassObject)
                            .padding(.bottom)
                        SystemInfo(NodeConnectionClassObject: nodeConnectionClassObject)
                            .frame(height: 200)
                            .padding(.bottom)
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(.quaternary)
                            VStack {
                                Toggle(!flag ? "50" : "", isOn: $flag)
                                    .padding(.all)
                                Spacer()
                            }
                        }
                            .frame(height: !flag ? 50 : 200)
                            .padding(.bottom)
                            .animation(.easeInOut, value: flag)
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            .ignoresSafeArea(edges: [.bottom])
        }
    }
}
