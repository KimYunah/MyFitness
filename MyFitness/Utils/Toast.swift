//
//  Toast.swift
//  MyFitness
//
//  Created by UMCios on 2023/09/26.
//

import UIKit

class Toast {
    
    static let shared = Toast()
    
    private init() {
    }
    
    private var activeToasts = NSMutableArray()
    
    func showToast(_ message: String) {
        guard let window = UIApplication.shared.windows.last(where: { $0.isKeyWindow }) else {
            return
        }
        
        if let activeToast = activeToasts.firstObject as? UILabel {
            activeToasts.remove(activeToast)
            activeToast.removeFromSuperview()
        }
        
        let messageLabel = UILabel()
        messageLabel.alpha = 0.0
        messageLabel.text = message
        messageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.textColor = UIColor.white
        messageLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        messageLabel.layer.cornerRadius = 10.0
        messageLabel.clipsToBounds = true
        messageLabel.numberOfLines = 0
        
        let maxMessageSize = CGSize(width: (window.frame.size.width * 0.8), height: window.frame.size.height * 0.8)
        let messageSize = messageLabel.sizeThatFits(maxMessageSize)
        let actualWidth = min(messageSize.width, maxMessageSize.width) + 20
        let actualHeight = min(messageSize.height, maxMessageSize.height) + 15
        messageLabel.frame = CGRect(x: (window.frame.size.width - actualWidth) / 2, y: window.frame.size.height - actualHeight * 3 - window.safeAreaInsets.bottom, width: actualWidth, height: actualHeight)
        
        activeToasts.add(messageLabel)
        window.addSubview(messageLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            messageLabel.alpha = 1.0
        }) { _ in
            let timer = Timer(timeInterval: 2.5, target: self, selector: #selector(self.toastTimerDidFinish(_:)), userInfo: messageLabel, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            self.activeToasts.remove(toast)
            toast.removeFromSuperview()
        }
    }
    
}
