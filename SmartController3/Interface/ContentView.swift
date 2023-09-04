//
//  ContentView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var nodeConnectionClassObject = NodeConnection()
    
//    @State private var flag = false
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
                        

                        SlowMode(nodeConnectionClass: nodeConnectionClassObject)
                            .frame(height: 50)
                            .padding(.bottom)
                        
                    }
                }
                .padding([.leading, .bottom, .trailing])
            }
            .ignoresSafeArea(edges: [.bottom])
        }
    }
}
