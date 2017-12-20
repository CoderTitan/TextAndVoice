//
//  ViewController.swift
//  TextAndVoice
//
//  Created by iOS_Tian on 2017/12/18.
//  Copyright © 2017年 CoderJun. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var titleArr = ["文字转语音", "实时语音转换文本", "本地语音转换文本", "一段录音转文字"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "列表"
    }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = titleArr[indexPath.row]
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = .none
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcs = [TextToVoiceController(), RealDataRecordController(), LocalVoiceController(), VoiceToTextController()]
        let vc = vcs[indexPath.row]
        vc.title = titleArr[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
