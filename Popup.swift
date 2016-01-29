//
//  Popup.swift
//  Taxy
//
//  Created by Artem Valiev on 04.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import OpinionzAlertView

final class Popup {
    static let instanse = Popup()
    var alert = OpinionzAlertView()
    final var handler: (Int -> Void)? 
    private func dismiss() -> Void {
        alert.delegate = nil
        alert.dismiss()
    }
    

    
    func showInfo(title: String, message: String) -> Self {
        show(title, message: message, type: 1, otherButtonTitles: [])
        return self
    }
    
    func showError(title: String = "Ошибка", message: String, otherButtons: [String]? =  nil) -> Self {
        show(title, message: message, type: 2, otherButtonTitles: otherButtons ?? [])
        return self
    }
    
    func showSuccess(title: String, message: String) -> Self {
        show(title, message: message, type: 3, otherButtonTitles: [])
        return self
    }

    func showQuestion(title: String, message: String, otherButtons: [String], cancelButtonTitle: String = "Закрыть") -> Self {
        show(title, message: message, type: 1, otherButtonTitles: otherButtons, cancelButtonTitle: cancelButtonTitle)
        return self
    }
    
    private func show(title: String, message: String, type: UInt, otherButtonTitles: [String], cancelButtonTitle: String = "Закрыть") -> Void {
        dismiss()
        handler = nil
        alert = OpinionzAlertView(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, usingBlockWhenTapButton: { alert, index in
            self.handler?(index)
        })
        
        alert.iconType = OpinionzAlertIcon.init(rawValue: type)
        alert.show()
    }
    
    
//    func show(title: String, message: String, delegate: UIViewController, cancelButton: String, otherButtons: [String]) -> Void {
//        alert = OpinionzAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButton, otherButtonTitles: otherButtons)
//        alert.show()
//    }
    
    
    final func handler(index: (Int -> Void)) -> Self{
        handler = index
        return self
    }
    
    
    
    func whisper(message: String) {
//        let message = Message(title: message, color: UIColor.redColor())
//        Whisper(m
    }
    
}