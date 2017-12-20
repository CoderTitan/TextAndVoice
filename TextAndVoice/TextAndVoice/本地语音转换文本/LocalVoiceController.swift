//
//  LocalVoiceController.swift
//  TextAndVoice
//
//  Created by iOS_Tian on 2017/12/20.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class LocalVoiceController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    fileprivate var recordTask: SFSpeechRecognitionTask?///语音识别对象的结果
    fileprivate lazy var recordRequest: SFSpeechURLRecognitionRequest = {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "再别康桥", ofType: "mp3") ?? "")
        let recordRequest = SFSpeechURLRecognitionRequest(url: url)
        recordRequest.shouldReportPartialResults = true
        return recordRequest
    }()
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
    
    //开始/停止识别
    @IBAction func recogedAction(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("开始")
        recordButton.setTitle(isStart ? "停止语音识别" : "开始语音识别", for: .normal)
        isStart ? startRecognize() : stopRecognize()
    }
    
}

extension LocalVoiceController{
    //开始识别
    fileprivate func startRecognize(){
        stopRecognize()
        
        //开始识别获取文字
        recordTask = recognizer.recognitionTask(with: recordRequest, resultHandler: { (result, error) in
            if result == nil { return }
            var text = ""
            for trans in result!.transcriptions{
                text += trans.formattedString
            }
            self.textLabel.text = text
        })
    }
    
    //停止识别
    fileprivate func stopRecognize(){
        if recordTask != nil{
            recordTask?.cancel()
            recordTask = nil
        }
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
                self.recordButton.isEnabled = isEnable
                self.recordButton.backgroundColor = isEnable ? UIColor(red: 255/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1) : UIColor.lightGray
            }
        }
    }
}


extension LocalVoiceController: SFSpeechRecognizerDelegate{
    //语音识别是否可用
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        recordButton.isEnabled = available
    }
}
