//
//  VoiceToTextController.swift
//  TextAndVoice
//
//  Created by iOS_Tian on 2017/12/18.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class VoiceToTextController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var speechButton: UIButton!
    
    //MARK: 录音/播放相关
    fileprivate var recordTime = 0 //录音时长
    fileprivate var playTime = 0 //播放时长
    fileprivate var recordTimer: Timer? //录音定时器
    fileprivate var playTimer: Timer?//播放定时器
    fileprivate var audioPlay = AVAudioPlayer()//播放器
    fileprivate var audioRecord: AVAudioRecorder?//录音器
    fileprivate lazy var audioSession: AVAudioSession = {//音频会话者
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setMode(AVAudioSessionModeMeasurement)
            try session.setActive(true, with: .notifyOthersOnDeactivation)
        }catch{
            print("Throws：\(error)")
        }
        return session
    }()
    
    //MARK: 语音识别功能
//    fileprivate var recordRequest = SFSpeechAudioBufferRecognitionRequest()///处理语音识别请求
    fileprivate var recordTask = SFSpeechRecognitionTask()///语音识别对象的结果
    fileprivate var audioEngine = AVAudioEngine()
    fileprivate lazy var recognizer: SFSpeechRecognizer = {//
        let recognize = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        recognize?.delegate = self
        return recognize!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAVFoundation()
        addSpeechRecordLimit()
    }
    
    fileprivate func setupAVFoundation(){
        //1. 初始化录音设备
        let recordSetting = [
            //采样率  8000/11025/22050/44100/96000（影响音频的质量）
            AVSampleRateKey: NSNumber(value: 8000),
            //音频格式
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
            //采样位数  8、16、24、32 默认为16
            AVLinearPCMBitDepthKey: NSNumber(value: 16),
            //音频通道数 1 或 2
            AVNumberOfChannelsKey: NSNumber(value: 1),
            //录音质量
            AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.high.rawValue))
        ]
        do{
            try audioRecord = AVAudioRecorder(url: saveDirectoryURL(), settings: recordSetting)
        }catch{
            print("Throws：\(error)")
        }
    }

    //开始/停止录音
    @IBAction func recordAction(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("开始")
        recordButton.setTitle(isStart ? "停止录音" : "开始录音", for: .normal)
        isStart ? startRecord() : stopRecord()
    }
    
    //语音转文本
    @IBAction func startTranslation(_ sender: UIButton) {
        
        let recordRequest = SFSpeechURLRecognitionRequest(url: audioRecord!.url)
        recordRequest.shouldReportPartialResults = true
        recordTask = recognizer.recognitionTask(with: recordRequest, resultHandler: { (result, error) in
            let text = result?.bestTranscription.formattedString
            self.recordLabel.text = text
        })
    }
    
    //语音播放
    @IBAction func playRecordAction(_ sender: UIButton) {
        //启动定时器
        playTime = recordTime
        playTimer = Timer(timeInterval: 1, target: self, selector: #selector(playTimerAction(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(playTimer!, forMode: .commonModes)
        
        if !audioRecord!.isRecording {
            do{
                try audioPlay = AVAudioPlayer(contentsOf: audioRecord!.url)
            }catch{
                print("Throws：\(error)")
            }
            audioPlay.play()
        }
    }
}

//MARK: 语音转换
extension VoiceToTextController{
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
                self.speechButton.isEnabled = isEnable
                self.speechButton.backgroundColor = isEnable ? UIColor(red: 255/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1) : UIColor.lightGray
            }
        }
    }
}

//MARK:
extension VoiceToTextController: SFSpeechRecognizerDelegate{
    
}

//MARK: 录音
extension VoiceToTextController{
    //停止录音
    fileprivate func stopRecord(){
        if audioRecord!.isRecording {
            audioRecord?.stop()
        }
        timeLabel.text = "录音时长\(recordTime)秒"
        removeRecordTimer()
    }
    
    //开始录音
    fileprivate func startRecord(){
        recordTime = 0
        
        //1. 启动定时器
        recordTimer = Timer(timeInterval: 1, target: self, selector: #selector(timerAutoScroll(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(recordTimer!, forMode: .commonModes)
        
        //2. 准备录音
        audioRecord?.prepareToRecord()
        
        //3. 开始录音
        audioRecord?.record()
    }
    
    //录音保存路径
    fileprivate func saveDirectoryURL() -> URL{
        //按照时间为文件名存储, 格式为.caf
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let recordName = formatter.string(from: currentDate) + ".caf"
        
        //存储路径
        let filMan = FileManager.default
        let url = filMan.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(string: "")!
        return url.appendingPathComponent(recordName)
    }
}

//MARK: 定时器方法
extension VoiceToTextController{
    //播放定时器方法
    @objc fileprivate func playTimerAction(_ sender:Timer){
        playTime -= 1
        timeLabel.text = "\(playTime)秒"
        if playTime <= 0{
            timeLabel.text = "播放结束"
            removePlayTimer()
        }
    }
    
    //录音定时器方法
    @objc fileprivate func timerAutoScroll(_ sender:Timer){
        recordTime += 1
        timeLabel.text = "\(recordTime)秒"
    }
    
    //销毁录音定时器
    fileprivate func removeRecordTimer(){
        if recordTimer != nil {
            recordTimer?.invalidate()
            recordTimer = nil
        }
    }
    
    //销毁播放定时器
    fileprivate func removePlayTimer(){
        if playTimer != nil {
            playTimer?.invalidate()
            playTimer = nil
        }
    }
}

/*
 //1. 定义音频的编码参数，决定录制音频文件的格式、音质、容量大小等
 let recordSetting = [
 //采样率  8000/11025/22050/44100/96000（影响音频的质量）
 AVSampleRateKey: NSNumber(value: 8000),
 //音频格式
 AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
 //采样位数  8、16、24、32 默认为16
 AVLinearPCMBitDepthKey: NSNumber(value: 16),
 //音频通道数 1 或 2
 AVNumberOfChannelsKey: NSNumber(value: 1),
 //录音质量
 AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.high.rawValue))
 ]
 */
