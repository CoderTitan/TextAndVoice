# TextAndVoice
# Swift语音和文本的转换
> 相关博客
- 简书地址: http://www.jianshu.com/p/aa4b44e192fd
- CSDN地址: http://blog.csdn.net/ShmilyCoder/article/details/78872486
- GitHub地址: https://github.com/CoderTitan/TextAndVoice

> 谈到语音和文本的转换, 就要说到语音转文本和文本转语音两大技术
- 文本转语音是iOS7以后的技术, 用到的是AVFoundation框架
- 语音转文本是iOS10以后, 苹果发布的一个`Speech`框架
- 下面先介绍一下简单的文本转语音
- [GitHub上Demo地址](https://github.com/CoderTitan/TextAndVoice)
- 项目包括
  - 文本转语音
  - 实时语音转文本
  - 本地语音转文本
  - 录音保存本地,转文本

## 一. 文本转语音
- 文本转语音技术, 简称TTS (是`Text To Speech`的缩写), [语音合成苹果官方文档](https://developer.apple.com/documentation/avfoundation/speech_synthesis)
- 是苹果iOS7以后新增的功能, 使用AVFoundation 库
- 下面介绍一下需要用到的类

### 1. `AVSpeechSynthesizer`: 语音合成器
#### 1-1. 属性

```
//是否正在语音播放
open var isSpeaking: Bool { get }

//是否停止语音播放
open var isPaused: Bool { get }
```

#### 1-2. 方法

```
//播放语音
open func speak(_ utterance: AVSpeechUtterance)

//停止语音播放
open func stopSpeaking(at boundary: AVSpeechBoundary) -> Bool

//暂停语音播放
open func pauseSpeaking(at boundary: AVSpeechBoundary) -> Bool

//继续语音播放
open func continueSpeaking() -> Bool

//(iOS10以上, 输出通道)
open var outputChannels: [AVAudioSessionChannelDescription]?
```

### 2. AVSpeechBoundary
- 描述语音可能被暂停或停止的枚举值

```
case immediate
//表示发言应该暂停或立即停止。

case word
//说完整个词语之后再暂停或者停止
```

### 3. AVSpeechUtterance
- 可以将文本和成一段语音的类, 或者说就是一段要播放的语音
#### 3-1. 属性

```
//使用的声音
open var voice: AVSpeechSynthesisVoice?

//文本属性    
open var speechString: String { get }

//富文本属性
@available(iOS 10.0, *)
open var attributedSpeechString: NSAttributedString { get }

//说话的速度    
open var rate: Float 
//提供了两个语速 AVSpeechUtteranceMinimumSpeechRate和 AVSpeechUtteranceMaximumSpeechRate和AVSpeechUtteranceDefaultSpeechRate

//说话的基线音高, [0.5 - 2] Default = 1   
open var pitchMultiplier: Float 

//说话音量, [0-1] Default = 1
open var volume: Float 

//开始一段语音之前等待的时间
open var preUtteranceDelay: TimeInterval 

//语音合成器在当前语音结束之后处理下一个排队的语音之前需要等待的时间, 默认0.0 
open var postUtteranceDelay: TimeInterval
```

#### 3-2. 初始化方法

```
public init(string: String)

@available(iOS 10.0, *)
public init(attributedString string: NSAttributedString)
```

### 4. AVSpeechSynthesisVoice
- 用于语音合成的独特声音, 主要是不同的语言和地区
- 所支持的所有语言种类详见最底部附录

#### 4-1. 相关属性

```
//获得当前的语言
open var language: String { get }

//返回用户当前语言环境的代码
@available(iOS 9.0, *)
open var identifier: String { get }

@available(iOS 9.0, *)
open var name: String { get }

@available(iOS 9.0, *)
open var quality: AVSpeechSynthesisVoiceQuality { get }

```

#### 4-2. 相关方法

```
init?(language: String?)
//返回指定语言和语言环境的语音对象。

class func speechVoices()
//返回所有可用的语音。


class func currentLanguageCode()
//返回用户当前语言环境的代码。
```


### 5. AVSpeechSynthesizerDelegate代理
- 所有代理方法都是支持iOS7.0以上的系统

```
//开始播放
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)

//播放完成
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)

//暂停播放
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance)

//继续播放
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance)

//取消播放
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)

//将要播放某一段话  
optional public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance)

```

### 6. 具体功能的核心代码

```
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

```

## 二. 语音转文本
- 在2016 WWDC大会上，Apple公司介绍了一个很好的语音识别的API,那就是Speech框架
- Speech框架支持iOS10以上系统
- [Speech框架官方文档](https://developer.apple.com/documentation/speech)
- 下面简单介绍一下主要的操作类

### 1. `SFSpeechRecognizer`: 语音识别器
- 这个类是语音识别的操作类
- 用于语音识别用户权限的申请，语言环境的设置，语音模式的设置以及向Apple服务发送语音识别的请求
- 初始化方法

```
//这个初始化方法将默认以设备当前的语言环境作为语音识别的语言环境
public convenience init?() 

//根据支持的语言初始化
public init?(locale: Locale) 
//示例
let recognize = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
```
- 类方法

```
//获取所有支持的语言
open class func supportedLocales() -> Set<Locale>

//获取当前用户权限状态
open class func authorizationStatus() -> SFSpeechRecognizerAuthorizationStatus

//申请语音识别用户权限
open class func requestAuthorization(_ handler: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Swift.Void)
```

- 其他属性

```
var isAvailable: Bool
//指示语音识别器是否可用

var locale: Locale
//当前语音识别器的语言环境

class func supportedLocales()
//获取语音识别所有支持的语言

var queue: OperationQueue
//语音识别器用于识别任务处理程序和委托消息的队列
```

- 相关方法

```
//识别与指定请求关联的音频来源的语音，使用指定的协议返回结果
open func recognitionTask(with request: SFSpeechRecognitionRequest, resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Swift.Void) -> SFSpeechRecognitionTask

//识别与指定请求关联的音频源的语音, 使用闭包结果
open func recognitionTask(with request: SFSpeechRecognitionRequest, delegate: SFSpeechRecognitionTaskDelegate) -> SFSpeechRecognitionTask
```
- 代理

```
weak var delegate: SFSpeechRecognizerDelegate? { get set }

//代理方法: 监视语音识别器的可用性
func speechRecognizer(SFSpeechRecognizer, availabilityDidChange: Bool)
```

### 2. `SFSpeechRecognitionRequest`
- 语音识别请求类，需要通过其子类来进行实例化
- 相关属性

```

var contextualStrings: [String]
//一系列应该被识别的语言种类

var shouldReportPartialResults: Bool
//是否获取每个语句的最终结果。

var taskHint: SFSpeechRecognitionTaskHint
//正在执行的语音识别的类型

var interactionIdentifier: String?
//标识与请求关联的识别请求对象的字符串
```
- 子类
  - `SFSpeechURLRecognitionRequest`
  - `SFSpeechAudioBufferRecognitionRequest`

#### 2-1. `SFSpeechURLRecognitionRequest`
- 通过制定的URL路径识别本地的语音
- 方法和属性

```
//创建一个语音识别请求，使用指定的URL进行初始化
public init(url URL: URL)

//获取当前的usl路径    
open var url: URL { get }
```

#### 2-2. `SFSpeechAudioBufferRecognitionRequest`
- 识别音频缓冲区中提供的语音的请求
- 识别即时语音, 类似于iPhone 中的Siri
- [官方文档](https://developer.apple.com/documentation/speech/sfspeechaudiobufferrecognitionrequest)
- 音频缓冲区相关方法属性

```
func append(AVAudioPCMBuffer)
//将PCM格式的音频追加到识别请求的末尾。

func appendAudioSampleBuffer(CMSampleBuffer)
//将音频附加到识别请求的末尾。

func endAudio()
//完成输入

```
- 获取音频格式

```
var nativeAudioFormat: AVAudioFormat
//用于最佳语音识别的首选音频格式。
```

### 3. `SFSpeechRecognitionTask`
- 语音识别请求结果类
- 语音识别任务，监视识别进度
- 相关方法属性

```
func cancel()
//取消当前的语音识别任务。

var isCancelled: Bool
//语音识别任务是否已被取消。

func finish()
//停止接受新的音频，并完成已接受的音频输入处理

var isFinishing: Bool
//音频输入是否已停止。

var state: SFSpeechRecognitionTaskState
//获取语音识别任务的当前状态。

var error: Error?
//在语音识别任务期间发生的错误的错误对象。

```

#### 3-1. `SFSpeechRecognitionTaskDelegate`协议

```
//当开始检测音频源中的语音时首先调用此方法
optional public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask)

//当识别出一条可用的信息后 会调用
//apple的语音识别服务会根据提供的音频源识别出多个可能的结果 每有一条结果可用 都会调用此方法
optional public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription)

//当识别完成所有可用的结果后调用
optional public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult)

//当不再接受音频输入时调用 即开始处理语音识别任务时调用   
optional public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask)

//当语音识别任务被取消时调用    
optional public func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask)

//语音识别任务完成时被调用    
optional public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool)

```

### 4. SFTranscription
- 语音转换后的信息类, 包含改短语音信息的类
- 你所说的一句话，可能是有好几个词语拼成的，`formattedString`就是你所说的那句话，`segments`就是你所说的你那句话的组成每个单词的集合

```
//返回了一条表达语音译文的字符数据
open var formattedString: String { get }

//所有的可能的识别数据
open var segments: [SFTranscriptionSegment] { get }

```

### 5. SFTranscriptionSegment
- 语音转换中的音频节点类
- 相关属性

```
//当前节点识别后的文本信息
open var substring: String { get }

//当前节点识别后的文本信息在整体识别语句中的位置
open var substringRange: NSRange { get }

//当前节点的音频时间戳
open var timestamp: TimeInterval { get }

//当前节点音频的持续时间
open var duration: TimeInterval { get }

//可信度/准确度 0-1之间
open var confidence: Float { get }

//关于此节点的其他可能的识别结果 
open var alternativeSubstrings: [String] { get }

```

### 6. `SFSpeechRecognitionResult`: 语音识别结果类
- 是语音识别结果的封装，其中包含了许多套平行的识别信息，其每一份识别信息都有可信度属性来描述其准确程度
- 该类只是语音识别结果的一个封装，真正的识别信息定义在SFTranscription类中

```
//准确性最高的识别实例
@NSCopying open var bestTranscription: SFTranscription { get }

//识别到的多套语音转换信息数组 其会按照准确度进行排序
open var transcriptions: [SFTranscription] { get }

//是否已经完成 如果YES 则所有所有识别信息都已经获取完成
open var isFinal: Bool { get }
```

## 三. 语音识别转文本
- 添加Speech框架
  - `import Speech`
- `info.plist`必须添加相关权限

```
Privacy - Speech Recognition Usage Description
//语音识别权限

Privacy - Microphone Usage Description
//麦克风使用权限
```
- 判断用户授权
  - 在使用speech framework做语音识别之前，你必须首先得到用户的允许
  - 因为不仅仅只有本地的ios设备会进行识别，苹果的服务器也会识别
  - 所有的语音数据都会被传递到苹果的后台进行处理
  - 因此，获取用户授权是强制必须的


```
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


```
- 再然后就是初始化相关请求和识别类处理相关语音
- [详细代码参考GitHub的Demo地址](https://github.com/CoderTitan/TextAndVoice)

---

## 附录: 
### `AVSpeechSynthesisVoice`支持的语言种类
```
         ar-SA  沙特阿拉伯（阿拉伯文）

         en-ZA, 南非（英文）

         nl-BE, 比利时（荷兰文）

         en-AU, 澳大利亚（英文）

         th-TH, 泰国（泰文）

         de-DE, 德国（德文）

         en-US, 美国（英文）

         pt-BR, 巴西（葡萄牙文）

         pl-PL, 波兰（波兰文）

         en-IE, 爱尔兰（英文）
         
         el-GR, 希腊（希腊文）

         id-ID, 印度尼西亚（印度尼西亚文）

         sv-SE, 瑞典（瑞典文）

         tr-TR, 土耳其（土耳其文）

         pt-PT, 葡萄牙（葡萄牙文）

         ja-JP, 日本（日文）

         ko-KR, 南朝鲜（朝鲜文）

         hu-HU, 匈牙利（匈牙利文）

         cs-CZ, 捷克共和国（捷克文）

         da-DK, 丹麦（丹麦文）

         es-MX, 墨西哥（西班牙文）

         fr-CA, 加拿大（法文）

         nl-NL, 荷兰（荷兰文）

         fi-FI, 芬兰（芬兰文）
         
         es-ES, 西班牙（西班牙文）

         it-IT, 意大利（意大利文）

         he-IL, 以色列（希伯莱文，阿拉伯文）

         no-NO, 挪威（挪威文）

         ro-RO, 罗马尼亚（罗马尼亚文）

         zh-HK, 香港（中文）

         zh-TW, 台湾（中文）

         sk-SK, 斯洛伐克（斯洛伐克文）

         zh-CN, 中国（中文）

         ru-RU, 俄罗斯（俄文）

         en-GB, 英国（英文）

         fr-FR, 法国（法文）
         
         hi-IN  印度（印度文）
```

