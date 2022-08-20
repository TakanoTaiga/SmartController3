//
//  ROSView.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/08/20.
//

import SwiftUI

struct ROSView: View {
    @State var power = 0.0
    @State var anguler = 0.0
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            VStack{
                HStack{
                    Button(action: {
                        
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("C1")
                                .foregroundColor(.white)
                        }
                    })
                    Button(action: {
                        
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("C2")
                                .foregroundColor(.white)
                        }
                    })
                }
                
                Spacer()
                Slider(value: $power ,in: 0...100 , step: 1)
                Text("Power:\(Int(power))")
                
                Spacer()
                Slider(value: $anguler ,in: 0...100 , step: 1)
                Text("Angular:\(Int(anguler))")
                Spacer()
            }
            .padding(.all)
        }
    }
}
