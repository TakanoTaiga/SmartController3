//
//  DebugTerminal.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/07/14.
//

import SwiftUI

struct DebugTerminal: View {
    @ObservedObject var GCC : GameControllerClass
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            VStack{
                Text(nowTime() + GCC.debugData)
                    .padding(.all)
                Spacer()
            }
        }
    }
    
    func nowTime() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        return format.string(from: Date())
    }
}
