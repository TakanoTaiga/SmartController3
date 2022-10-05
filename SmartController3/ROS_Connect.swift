//
//  UDPControllerClass.swift
//  SmartRobotController
//
//  Created by 高野大河 on 2021/08/14.
//

import Network
import SystemConfiguration
import CoreTelephony
import AVFoundation

struct paramROSConnect{
    var nodeIP : NWEndpoint.Host
    var deviceName : String
    var nodeName : String
    var nodeLife : Bool
    var customButtonLabel1 : String
    var customButtonLabel2 : String
    var customSliderLabel1 : String
    var customSliderLabel2 : String
    var log4NWError : String
    var smartuiInfomation : String
    var smartuiError : String
}

class ROSConnect : ObservableObject{
    private let initParamROSConnect = paramROSConnect(nodeIP: NWEndpoint.Host(""),
                                                      deviceName: "",
                                                      nodeName: "",
                                                      nodeLife: false,
                                                      customButtonLabel1: "" ,
                                                      customButtonLabel2: "",
                                                      customSliderLabel1: "" ,
                                                      customSliderLabel2: "",
                                                      log4NWError: "Not Connected" ,
                                                      smartuiInfomation: "" ,
                                                      smartuiError: "")
    
    @Published var log4ROSC : paramROSConnect
    @Published var counter = 0
    
    private var speaker : NWConnection? //Handler
    private var speakerForROS : NWConnection?
    private var listener = try! NWListener(using: .udp, on: 64201) //Handler
    
    private let udpQueue = DispatchQueue(label: "UDPQueue" , qos: .userInteractive , attributes: .concurrent)
    
    
    private var nodeCheckTimer : Timer!
    private var getNetInfoHndlr = GetNetworkInfomationHandler()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    
    private func send(item : String){
        let payload = item.data(using: .utf8)!
        self.speaker!.send(content: payload, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                NSLog("ROSC:Send:Data was sent to UDP")
                DispatchQueue.main.async {
                    self.counter += 1
                }
            } else {
                NSLog("ROSC:Send:NWError:\(NWError!)")
            }
        })))
    }
    
    private func SearchROSNode(){
        self.speakerForROS!.send(content: "WHATISNODEIP".data(using: .utf8)!, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                DispatchQueue.main.async {
                    NSLog("ROSC:SROSN:Data was sent to UDP")
                    self.counter += 1
                }
                
            } else {
                DispatchQueue.main.async {
                    NSLog("ROSC:SROSN:NWError:\(NWError!)")
                    self.speakerForROS = NWConnection(host: "255.255.255.255", port: 64201, using: .udp)
                    self.speakerForROS!.start(queue: self.udpQueue)
                }
            }
        })))
    }
    
    private func NodeCheckHandler(){
        NSLog("NodeCheckHandler:\(self.log4ROSC.nodeIP != NWEndpoint.Host(""))")
        if self.log4ROSC.nodeIP != NWEndpoint.Host(""){
            //Check Node life
            self.log4ROSC.nodeLife = false
            self.send(item: "PING")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                if self.log4ROSC.nodeLife{
                    //alive ros node
                    //Check Node infomation packet
                    if self.log4ROSC.deviceName == "" ||
                        self.log4ROSC.nodeName == "" ||
                        self.log4ROSC.customButtonLabel1 == "" ||
                        self.log4ROSC.customButtonLabel2 == "" ||
                        self.log4ROSC.customSliderLabel1 == "" ||
                        self.log4ROSC.customSliderLabel2 == ""
                    {
                        self.send(item: "WHOAREYOU")
                        self.log4ROSC.log4NWError = "Node infomation is breaked"
                    }else{
                        //full check complete
                        self.log4ROSC.log4NWError = ""
                    }
                    return
                }else{
                    //lost ros node
                    self.log4ROSC = self.initParamROSConnect
                    self.SearchROSNode()
                    let utterance = AVSpeechUtterance(string: "ロボットに接続できません")
                    utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                    utterance.rate = 0.5
                    self.synthesizer.speak(utterance)
                }
            }
        }else{
            //lost ros node
            self.log4ROSC = self.initParamROSConnect
            self.SearchROSNode()
//            let utterance = AVSpeechUtterance(string: "Unable to establish a connection")
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//            self.synthesizer.speak(utterance)
        }
    }
    
    public func resetStatus(){
        self.log4ROSC = self.initParamROSConnect
    }
    
    init(){
        self.log4ROSC = self.initParamROSConnect
        
        self.speakerForROS = NWConnection(host: "255.255.255.255", port: 64201, using: .udp)
        self.speakerForROS!.start(queue: self.udpQueue)
        
        self.listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.udpQueue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 100, completion: {(data,context,flag,error) in
                if let data = data{
                    
                    let rcvDataString = String(data: data, encoding: .utf8)!
                    NSLog("ROSC:init:listener:rcvDataString:" + rcvDataString)
                    
                    if rcvDataString.contains("MYNODEIP") {
                        //node ip
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeIP = NWEndpoint.Host(String(rcvDataString.dropFirst("MYNODEIP".count)))
                            self.speaker = NWConnection(host: self.log4ROSC.nodeIP, port: 64201, using: .udp)
                            self.speaker!.start(queue: self.udpQueue)
                            self.send(item: "WHOAREYOU")
                            self.log4ROSC.nodeLife = true
                            self.log4ROSC.log4NWError = ""
                        }
                    }
                    
                    if rcvDataString.contains("MYNAMEIS"){
                        // Host name
                        DispatchQueue.main.async {
                            self.log4ROSC.deviceName = String(rcvDataString.dropFirst("MYNAMEIS".count))
                            self.log4ROSC.nodeLife = true
                            self.send(item: "REQNODEPARAM")
                        }
                    }
                    
                    if rcvDataString.contains("MYNODEIS"){
                        // Node name
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeName = String(rcvDataString.dropFirst("MYNODEIS".count))
                            self.log4ROSC.nodeLife = true
                        }
                    }
                    
                    if rcvDataString.contains("CHECK"){
                        //PING ans
                        DispatchQueue.main.async {
                            self.log4ROSC.nodeLife = true
                            self.log4ROSC.log4NWError = ""
                        }
                    }
                    
                    if(rcvDataString.contains("C1LABEL")){
                        DispatchQueue.main.async {
                            self.log4ROSC.customButtonLabel1 = String(rcvDataString.dropFirst("C1LABEL".count))
                        }
                    }
                    
                    if(rcvDataString.contains("C2LABEL")){
                        DispatchQueue.main.async {
                            self.log4ROSC.customButtonLabel2 = String(rcvDataString.dropFirst("C2LABEL".count))
                        }
                    }
                    
                    if(rcvDataString.contains("S1LABEL")){
                        DispatchQueue.main.async {
                            self.log4ROSC.customSliderLabel1 = String(rcvDataString.dropFirst("S1LABEL".count))
                        }
                    }
                    
                    if(rcvDataString.contains("S2LABEL")){
                        DispatchQueue.main.async {
                            self.log4ROSC.customSliderLabel2 = String(rcvDataString.dropFirst("S2LABEL".count))
                        }
                    }
                    
                    if(rcvDataString.contains("SINFO")){
                        DispatchQueue.main.async{
                            self.log4ROSC.smartuiInfomation = String(rcvDataString.dropFirst("SINFO".count))
                        }
                    }
                       
                    if(rcvDataString.contains("SEMER")){
                        DispatchQueue.main.async{
                            self.log4ROSC.smartuiError = String(rcvDataString.dropFirst("SEMER".count))
                        }
                    }
                    
                    newConnection.cancel()
                }else{
                    newConnection.cancel()
                }
            })
        }
        self.listener.start(queue: self.udpQueue)
        
        self.NodeCheckHandler()
        self.nodeCheckTimer?.invalidate()
        self.nodeCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true){ _ in
            self.NodeCheckHandler()
        }
    }
}
