//
//  TaxyRequestingVC.swift
//  Taxy
//
//  Created by Artem Valiev on 13.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit

class TaxyRequestingVC: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelRequestButton: UIButton!
    var orderInfo: Order?
    var timer: NSTimer?
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelRequestButton.enabled = false
        if orderInfo == nil { // fast order
            Helper().getAddres {
                self.orderInfo?.fromPlace = $0.0
                self.orderInfo?.coordinates = $0.1
                self.createOrder()
            }
        } else {
            createOrder()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func createOrder() {
        Helper().showLoading("Создание заказа")
        Networking.instanse.createOrder(orderInfo!) { [weak self]  result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let orderID):
                self?.orderInfo?.orderID = orderID
                self?.cancelRequestButton.enabled = true
                
                if ((self?.timer = NSTimer.scheduledTimerWithTimeInterval(20, target: self!, selector: "monitorOrderStatus", userInfo: nil, repeats: true)) != nil) {
                    self?.timer!.fire()
                }
            }
        }
    }
    
    
    func monitorOrderStatus() {
        Networking.instanse.monitorOrderStatus(orderInfo!) { result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let orderStatus):
                debugPrint(orderStatus)
            }
        }
    }
    
    
    @IBAction func cancelTouched() {
        Networking.instanse.cancelOrder(orderInfo!) { result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                Popup.instanse.showInfo("Внимание!", message: "Ваш заказ отменен")
            }
        }
    }
    
    @IBAction func closeOrderTouched(sender: AnyObject) {
        Networking.instanse.closeOrder(orderInfo!) { result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                Popup.instanse.showInfo("Внимание!", message: "Заказа завершен")
            }
        }
    }
    
    
    
}






