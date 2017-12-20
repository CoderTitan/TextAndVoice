//
//  TextToVoiceController.swift
//  TextAndVoice
//
//  Created by iOS_Tian on 2017/12/18.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit
import AVFoundation

class TextToVoiceController: UIViewController {
    
    fileprivate let avSpeech = AVSpeechSynthesizer()

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var willSpeekLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "文字转语音"
        avSpeech.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancleSpeek()
    }

    //开始转换
    @IBAction func translationAction(_ sender: UIButton) {
        let isStart = sender.currentTitle!.contains("开始")
        textView.resignFirstResponder()
        startButton.setTitle(isStart ? "取消播放" : "开始播放", for: .normal)
        isStart ? startTranslattion() : cancleSpeek()
    }
    
    //暂停播放
    @IBAction func pauseOrContinueAction(_ sender: UIButton) {
        let isPause = sender.currentTitle!.contains("暂停")
        pauseButton.setTitle(isPause ? "继续播放" : "暂停播放", for: .normal)
        isPause ? pauseTranslation() : continueSpeek()
    }
    
}

//MARK: 开始/停止转换
extension TextToVoiceController{
    //开始转换
    fileprivate func startTranslattion(){
        //1. 创建需要合成的声音类型
        let voice = AVSpeechSynthesisVoice(language: "zh-CN")
        
        //2. 创建合成的语音类
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = voice
        utterance.volume = 1
        utterance.postUtteranceDelay = 0.1
        utterance.pitchMultiplier = 1
        //开始播放
        avSpeech.speak(utterance)
    }
    
    //暂停播放
    fileprivate func pauseTranslation(){
        avSpeech.pauseSpeaking(at: .immediate)
    }
    
    //继续播放
    fileprivate func continueSpeek(){
        avSpeech.continueSpeaking()
    }
    
    //取消播放
    fileprivate func cancleSpeek(){
        avSpeech.stopSpeaking(at: .immediate)
    }
}

//MARK: AVSpeechSynthesizerDelegate
extension TextToVoiceController: AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("开始播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        startButton.setTitle("开始播放", for: .normal)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("暂停播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("继续播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("取消播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        print(characterRange.location, "-----", characterRange.length)
        let subStr = utterance.speechString.dropFirst(characterRange.location).description
        let rangeStr = subStr.dropLast(subStr.count - characterRange.length).description
        willSpeekLabel.text = rangeStr
    }
}
