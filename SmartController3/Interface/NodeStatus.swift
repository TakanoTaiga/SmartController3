//
//  NodeStatus.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/03/10.
//

import SwiftUI

struct NodeStatus: View {
    @ObservedObject var nodeConnectionClassObject : NodeConnection
    @State var timer : Timer!
    @State private var degree: Int = 0
    var body: some View {
        if(nodeConnectionClassObject.state == robot_state.failed){
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
                    .rotationEffect(Angle(degrees: Double(degree)))
                    .font(.caption)
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false) , value: degree)
                    .onAppear {
                        self.degree = 360
                    }
                Text("Search Node")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .onAppear(){
                timer?.invalidate()
            }
            .onDisappear(){
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ _ in
                    nodeConnectionClassObject.sendGameControllerStatus()
                }
            }
            
        }else{
            HStack {
                Image(systemName: "personalhotspot")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                if(nodeConnectionClassObject.name != ""){
                    Text(nodeConnectionClassObject.name + ".local")
                        .foregroundStyle(.secondary)
                }else{
                    Text("接続中")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
    }
}
