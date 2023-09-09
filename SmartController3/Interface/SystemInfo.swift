//
//  ROSInfomation.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI

struct SystemInfo: View {
    @ObservedObject var NodeConnectionClassObject: NodeConnection
    @Namespace var bottomID
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.quaternary)
            
            HStack {
                Spacer()
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading) {
                        ForEach(NodeConnectionClassObject.consoleOut.indices.reversed(), id: \.self) { index in
                            HStack {
                                Spacer()
                                Text("\(NodeConnectionClassObject.consoleOut[index])")
                                    .id(index)
                                    .rotationEffect(Angle(degrees: 180))
                            }
                        }
                    }
                }
                .rotationEffect(Angle(degrees: 180))
            }
            .padding(.all)

        }
    }
}

