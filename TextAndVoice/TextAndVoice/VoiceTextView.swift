//
//  VoiceTextView.swift
//  TextAndVoice
//
//  Created by quanjunt on 2018/12/7.
//  Copyright © 2018 CoderJun. All rights reserved.
//

import UIKit

class VoiceTextView: UITextView {

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(lableClick)))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(lableClick)))
    }

    
    @objc fileprivate func lableClick() {
        becomeFirstResponder()
        
        let menu = UIMenuController.shared
        menu.setTargetRect(frame, in: superview ?? self)
        menu.setMenuVisible(true, animated: true)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(menu:)) {
            return true
        }
        return false
    }
    
    @objc fileprivate func copy(menu: UIMenuController) {
        let pause = UIPasteboard.general
        pause.string = self.text
    }
}
