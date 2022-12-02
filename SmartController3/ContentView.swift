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
        if UIDevice.current.userInterfaceIdiom == .phone {
            // for iPhone code
            HStack {
                Spacer()
                
                VStack{
                    Spacer()
                    PeformanceView(GCC: controllerClassObject , ROSConnectHandler: ROSConnectHandler)
                        .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 5, alignment: .center)
                    
                    Spacer()
                    
                    SmartUI(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
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
                        EmergencyCall()
                            .frame(width: UIScreen.main.bounds.height / 2.3, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
                            .padding(.all , 5)
                        Spacer()
                    }
                    
                    ROSInfomation(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
                        .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
                }
            }

        } else if UIDevice.current.userInterfaceIdiom == .pad {
           // for ipad code
            HStack {
                VStack{
                    PeformanceView(GCC: controllerClassObject , ROSConnectHandler: ROSConnectHandler)
                        .frame(height: 100)
                        .padding(.all)
                    
                    SmartUI(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
                        .padding(.all)
                }
                
                VStack {
                    HStack {
                        ControllerInfomationWidget(GameController: controllerClassObject)
                            .padding(.all)
                        EmergencyCall()
                            .padding(.all)
                    }
                    ROSInfomation(ROSConnectHandler: ROSConnectHandler , GCC: controllerClassObject)
                        .padding(.all)
                }
            }
        }
    }
}
