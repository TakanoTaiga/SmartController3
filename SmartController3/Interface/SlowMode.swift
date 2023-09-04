//
//  SlowMode.swift
//  SmartController3
//
//  Created by TaigaTakano on 2023/09/02.
//

import SwiftUI

struct SlowMode: View {
    @State var isTap = false
    @ObservedObject var nodeConnectionClass : NodeConnection
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(!isTap ? .quaternary : .primary)
                .foregroundColor(!isTap ? .gray : .red)
            Text(!isTap ? "Slow Mode OFF" : "Slow Mode ON")
                .opacity(!isTap ? 0.5 : 1.0)
                .foregroundColor(!isTap ? .black : .white)
                
        }
        .onTapGesture {
            isTap.toggle()
            if isTap {
                nodeConnectionClass.enable_slow_mode()
            }else{
                nodeConnectionClass.disable_slow_mode()
            }
        }
        .animation(.easeOut(duration: 0.1), value: isTap)

    }
}
