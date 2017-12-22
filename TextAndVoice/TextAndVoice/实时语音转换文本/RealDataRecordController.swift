//
//  RealDataRecordController.swift
//  TextAndVoice
//
//  Created by iOS_Tian on 2017/12/20.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class RealDataRecordController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    fileprivate var recordRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recordTask: SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate lazy var recognizer: SFSpeechRecognizer = {//
        let recognize = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        recognize?.delegate = self
        return recognize!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSpeechRecordLimit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecognize()
    }

    //开始/停止录音
    @IBAction func recordAction(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("开始")
        recordBtn.setTitle(isStart ? "停止录音" : "开始录音", for: .normal)
        isStart ? startRecognize() : stopRecognize()
    }
}

//MARK: 录音识别
extension RealDataRecordController{
    //开始识别
    fileprivate func startRecognize(){
        //1. 停止当前任务
        stopRecognize()
        
        //2. 创建音频会话
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryRecord)
            try session.setMode(AVAudioSessionModeMeasurement)
            //激活Session
            try session.setActive(true, with: .notifyOthersOnDeactivation)
        }catch{
            print("Throws：\(error)")
        }
        
        //3. 创建识别请求
        recordRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        //开始识别获取文字
        recordTask = recognizer.recognitionTask(with: recordRequest!, resultHandler: { (result, error) in
            if result != nil {
                var text = ""
                for trans in result!.transcriptions{
                    text += trans.formattedString
                }
                self.textLabel.text = text
                
                if result!.isFinal{
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recordRequest = nil
                    self.recordTask = nil
                    self.recordBtn.isEnabled = true
                }
            }
        })
        let recordFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordFormat, block: { (buffer, time) in
            self.recordRequest?.append(buffer)
        })
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Throws：\(error)")
        }
    }
    
    //停止识别
    fileprivate func stopRecognize(){
        if recordTask != nil{
            recordTask?.cancel()
            recordTask = nil
        }
        removeTask()
    }
    
    //销毁录音任务
    fileprivate func removeTask(){
        self.audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.recordRequest = nil
        self.recordTask = nil
        self.recordBtn.isEnabled = true
    }
    
    ///语音识别权限认证
    fileprivate func addSpeechRecordLimit(){
        SFSpeechRecognizer.requestAuthorization { (state) in
            var isEnable = false
            switch state {
            case .authorized:
                isEnable = true
                print("已授权语音识别")
            case .notDetermined:
                isEnable = false
                print("没有授权语音识别")
            case .denied:
                isEnable = false
                print("用户已拒绝访问语音识别")
            case .restricted:
                isEnable = false
                print("不能在该设备上进行语音识别")
            }
            DispatchQueue.main.async {
                self.recordBtn.isEnabled = isEnable
                self.recordBtn.backgroundColor = isEnable ? UIColor(red: 255/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1) : UIColor.lightGray
            }
        }
    }
}

//MARK:
extension RealDataRecordController: SFSpeechRecognizerDelegate{
    //监视语音识别器的可用性
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        recordBtn.isEnabled = available
    }
}
