//
//  ContentView.swift
//  SmartController3
//
//  Created by Taiga Takano on 2022/06/18.
//
import SwiftUI

struct ContentView: View {
    @ObservedObject var nodeConnectionClassObject = NodeConnection()
    
    @State private var showSettings = false
    @State private var showSystemInfo = true
    @State private var showSlowMode = false
    @State private var showBigSlowMode = false
    @State private var showEnergency = true
    @State private var showVersion = false
    @State private var pressGear = false
    @State private var needLongPress = false
    
    @State private var keyborad_open = false
    
    @State private var str = ""
    @State private var id_str = ""
    
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    var body: some View {
        ZStack {
            baseView()
            settingsView()
            longPressIndicator()
        }
        .onAppear(){
            showSystemInfo = UserDefaults.standard.object(forKey: "showSystemInfo") as? Bool ?? true
            showSlowMode = UserDefaults.standard.object(forKey: "showSlowMode") as? Bool ?? false
            showBigSlowMode = UserDefaults.standard.object(forKey: "showBigSlowMode") as? Bool ?? false
            showEnergency = UserDefaults.standard.object(forKey: "showEnergency") as? Bool ?? true
            nodeConnectionClassObject.slow_mode_value = UserDefaults.standard.object(forKey: "slow_mode_value") as? Float ?? 0.5
            nodeConnectionClassObject.comID = UserDefaults.standard.object(forKey: "comID") as? UInt8 ?? 10
            
        }
        .onDisappear(){
            UserDefaults.standard.set(showSystemInfo, forKey: "showSystemInfo")
            UserDefaults.standard.set(showSlowMode, forKey: "showSlowMode")
            UserDefaults.standard.set(showBigSlowMode, forKey: "showBigSlowMode")
            UserDefaults.standard.set(showEnergency, forKey: "showEnergency")
            UserDefaults.standard.set(nodeConnectionClassObject.slow_mode_value, forKey: "slow_mode_value")
            UserDefaults.standard.set(nodeConnectionClassObject.comID, forKey: "comID")
        }
    }
    
    // MARK: - Private Helpers
    private func baseView() -> some View {
        ZStack {
            backgroundGradient()
            VStack {
                nodeStatusView()
                ZStack{
                    HStack {
                        Spacer()
                        Text("ID: \(nodeConnectionClassObject.comID)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Rcv: \(nodeConnectionClassObject.rcvID[0])")
                            .foregroundStyle(.secondary)
                        if(nodeConnectionClassObject.rcvID[1] != 0){
                            Text("\(nodeConnectionClassObject.rcvID[1])")
                                .foregroundStyle(.secondary)
                        }
                        if(nodeConnectionClassObject.rcvID[2] != 0){
                            Text("\(nodeConnectionClassObject.rcvID[2])")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .animation(.easeIn(duration: 0.2), value: nodeConnectionClassObject.rcvID)
                }
                .padding(.all , 0.5)
                
                scrollViewContent()
            }
            .onTapGesture {
                showSettings = false
                UIApplication.shared.closeKeyboard()
            }
        }
    }
    
    private func backgroundGradient() -> some View {
        LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .onTapGesture {
                showSettings = false
                UIApplication.shared.closeKeyboard()
            }
    }
    
    private func nodeStatusView() -> some View {
        ZStack {
            NodeStatus(nodeConnectionClassObject: nodeConnectionClassObject)
                .padding(.horizontal)
                .blur(radius: needLongPress ? 5 : 0.0)
                .opacity(needLongPress ? 0.7 : 1.0)
                .animation(.easeIn(duration: 0.1), value: needLongPress)
            HStack {
                Spacer()
                longPressHint()
                gearIcon()
            }
        }
    }
    
    private func scrollViewContent() -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                if showBigSlowMode {
                    SlowMode(nodeConnectionClass: nodeConnectionClassObject)
                        .frame(height: 200)
                        .padding(.bottom)
                        .onAppear { showSlowMode = false }
                }
                ControllerInfomationWidget(nodeConnectionClass: nodeConnectionClassObject).padding(.bottom)
                if showSystemInfo {
                    SystemInfo(NodeConnectionClassObject: nodeConnectionClassObject)
                        .frame(height: 200)
                        .padding(.bottom)
                }
                if showSlowMode {
                    SlowMode(nodeConnectionClass: nodeConnectionClassObject)
                        .frame(height: 50)
                        .padding(.bottom)
                        .onAppear { showBigSlowMode = false }
                }
                
                if showEnergency {
                    EmergencyCall(nodeConnectionClass: nodeConnectionClassObject)
                        .frame(height: 150)
                }
            }
            .padding([.leading, .bottom, .trailing])
            
        }
    }
    
    private func longPressHint() -> some View {
        Text("長押ししてください")
            .font(.callout)
            .foregroundStyle(.secondary)
            .opacity(needLongPress ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.2), value: needLongPress)
    }
    
    private func gearIcon() -> some View {
        Image(systemName: "gear")
            .font(.title3)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .opacity(pressGear ? 0.5 : 1.0)
    }
    
    private func settingsView() -> some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .background(.ultraThinMaterial)
                    .shadow(radius: 10)
                VStack {
                    HStack {
                        Text(showVersion ? "\(version)(\(build))" : "設定")
                            .font(.headline)
                            .onTapGesture {
                                showVersion.toggle()
                            }
                            .animation(.easeInOut(duration: 0.2), value: showVersion)
                        Spacer()
                    }
                    Toggle("デバッグパネル", isOn: $showSystemInfo)
                    Toggle("スローモード", isOn: $showSlowMode)
                    Toggle("最大 スローモード", isOn: $showBigSlowMode)
                    Toggle("緊急停止", isOn: $showEnergency)
                    
                    HStack {
                        Text("SlowMode値")
                        Spacer()
                        TextField("0 to 1", text: $str)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                                keyborad_open = true
                                str = "\(nodeConnectionClassObject.slow_mode_value)"
                            }.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                                keyborad_open = false
                                if let fp = Float(str){
                                    nodeConnectionClassObject.slow_mode_value = fp
                                    UserDefaults.standard.set(nodeConnectionClassObject.slow_mode_value, forKey: "slow_mode_value")
                                }else{
                                    nodeConnectionClassObject.slow_mode_value = 0.0
                                    str = "\(nodeConnectionClassObject.slow_mode_value)"
                                }
                                
                            }
                    }
                    HStack {
                        Text("ID")
                        Spacer()
                        TextField("id", text: $id_str)
                            .keyboardType(.decimalPad)
                            .font(.headline)
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                                keyborad_open = true
                                id_str = "\(nodeConnectionClassObject.comID)"
                            }.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                                keyborad_open = false
                                if let ui = UInt8(id_str){
                                    nodeConnectionClassObject.comID = ui
                                    UserDefaults.standard.set(nodeConnectionClassObject.comID, forKey: "comID")
                                }else{
                                    nodeConnectionClassObject.comID = 0
                                    id_str = "\(nodeConnectionClassObject.comID)"
                                }
                                
                            }
                    }
                    
                    Spacer()
                }.padding(.all)
            }
            .frame(height: 350)
            .offset(y: showSettings ? 50 : 600)
            .offset(y: keyborad_open ? -50 : 0)
            .animation(.easeInOut(duration: 0.2), value: showSettings)
            .onTapGesture {
                UIApplication.shared.closeKeyboard()
                keyborad_open = false
            }
            .onAppear(){
                id_str = "\(nodeConnectionClassObject.comID)"
                str = "\(nodeConnectionClassObject.slow_mode_value)"
            }
        }
    }
    
    private func longPressIndicator() -> some View {
        VStack {
            Rectangle()
                .frame(height: 90)
                .opacity(0.0001)
                .gesture(longPressGesture())
            Spacer()
        }
    }
    
    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                showSettings.toggle()
                print("press")
            }
            .onChanged { _ in
                handleLongPressChange()
            }
    }
    
    private func handleLongPressChange() {
        pressGear = true //for gear animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
            pressGear = false //for gear animation
            if !showSettings{
                needLongPress = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                needLongPress = false
            }
        }
        
        if showSettings {
            showSettings = false
            UIApplication.shared.closeKeyboard()
        }
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
