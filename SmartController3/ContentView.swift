//
//  ContentView.swift
//  SmartController3
//
//  Created by 高野大河 on 2022/06/18.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var controllerClassObject = GameControllerClass()
    @ObservedObject var ROSConnectHandler = ROSConnect()
    var body: some View {
        HStack {
            Spacer()
            
            VStack{
                Spacer()
                DebugTerminal(GCC: controllerClassObject , ROSConnectHandler: ROSConnectHandler)
                    .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 5, alignment: .center)
                
                Spacer()
                
                ROSView(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
                    .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 1.5, alignment: .center)
                
                Spacer()
            }
            
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    ControllerInfomationWidget(GameController: controllerClassObject)
                        .frame(width: UIScreen.main.bounds.height / 2.3, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
                        .foregroundColor(.gray)
                    Spacer()
                    DeviceInforWidget(GameControllerClass: controllerClassObject)
                        .frame(width: UIScreen.main.bounds.height / 2.3, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
                        .padding(.all , 5)
                    Spacer()
                }
                
                ROSInfomation(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
                    .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
            }
        }
    }
}
