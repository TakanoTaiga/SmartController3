//
//  ContentView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var controllerClassObject = GameControllerClass()
    @ObservedObject var nodeConnectionClassObject = NodeConnection()
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            // for iPhone code
            HStack {
                Spacer()
                
                VStack{
                    Spacer()
                    NodeStatus(nodeConnectionClassObject: nodeConnectionClassObject , gameControllerClass: controllerClassObject)
                        .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 7, alignment: .center)
                    
                    Spacer()
                    
                    SmartUI(ROSConnectHandler: nodeConnectionClassObject , GCC: controllerClassObject)
                        .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 1.4, alignment: .center)
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
                    }
                    
                    SystemInfo(NodeConnectionClassObject: nodeConnectionClassObject)
                        .frame(width: UIScreen.main.bounds.height / 1.1, height: UIScreen.main.bounds.height / 2.3, alignment: .center)
                }
            }
            
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            // for ipad code
            HStack {
                VStack{
                    SmartUI(ROSConnectHandler: nodeConnectionClassObject , GCC: controllerClassObject)
                        .padding(.all)
                }
                
                VStack {
                    HStack {
                        ControllerInfomationWidget(GameController: controllerClassObject)
                            .padding(.all)
                        EmergencyCall()
                            .padding(.all)
                    }
                    SystemInfo(NodeConnectionClassObject: nodeConnectionClassObject)
                        .padding(.all)
                }
            }
        }
    }
}
