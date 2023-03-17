//
//  NodeStatus.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/03/10.
//

import SwiftUI

struct NodeStatus: View {
    @ObservedObject var nodeConnectionClassObject : NodeConnection
    @ObservedObject var gameControllerClass : GameControllerClass
    @State var timer : Timer!
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.brown)
                .opacity(0.1)
            
            if(nodeConnectionClassObject.nodeConnectionParameter.state == ServiceState.failed){
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("ノードを検索中")
                    Spacer()
                }
                .padding(.all)
                .onAppear(){
                    timer?.invalidate()
                }
                .onDisappear(){
                    gameControllerClass.NWSetup(host: nodeConnectionClassObject.nodeConnectionParameter.nodeIP)
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ _ in
                        gameControllerClass.sendGameControllerStatus()
                    }
                }
                
            }else{
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    if(nodeConnectionClassObject.nodeInfomation.hostName != ""){
                        Text(nodeConnectionClassObject.nodeInfomation.hostName + ".local")
                    }else{
                        Text("接続中")
                    }
                    
                    Spacer()
                }
                .padding(.all)
            }
        }
    }
}
