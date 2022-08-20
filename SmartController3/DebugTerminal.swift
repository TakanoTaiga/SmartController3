//
//  DebugTerminal.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/07/14.
//

import SwiftUI

struct DebugTerminal: View {
    @ObservedObject var GCC : GameControllerClass
    @ObservedObject var ROSConnectHandler : ROSConnect
    @State var timer : Timer!
    
    @State var status = Array<Int>(repeating: 0, count: 25)
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            VStack{
                Spacer()
                
                HStack{
                    ForEach(0..<status.count){num in
                        VStack{
                            Spacer()
                            showNetwork(trafic: status[num])
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
        }
        .onAppear(){
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1 , repeats: true){_ in
                for i in 0..<status.count - 1{
                    status[i] = status[i+1]
                }
                status[status.count - 1] = GCC.counter + ROSConnectHandler.counter
                GCC.counter = 0
                ROSConnectHandler.counter = 0
            }
        }
        .onDisappear(){
            timer?.invalidate()
        }
    }
    
    func nowTime() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return format.string(from: Date())
    }
}

struct showNetwork:View{
    var trafic : Int

    var body: some View{
        if(trafic < 50){
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 5, height: CGFloat(trafic), alignment: .bottom)
                .foregroundColor(.blue)
        }else{
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 5, height: 50, alignment: .bottom)
                .foregroundColor(.blue)
        }
    }
}
