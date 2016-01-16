//
//  TaxyRequestingVC.swift
//  Taxy
//
//  Created by Artem Valiev on 13.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit
import CCMRadarView

class TaxyRequestingVC: UIViewController {
    
    @IBOutlet weak var radarView: CCMRadarView!
    @IBOutlet weak var cancelRequestButton: UIButton!
    var orderInfo = Order()
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableMenu()
        navigationItem.hidesBackButton = true
        title = "Поиск такси"
        cancelRequestButton.enabled = false
        if orderInfo.fromPlace == nil { // fast order
            Helper().getAddres {
                self.orderInfo.fromPlace = $0.0
                self.orderInfo.coordinates = $0.1
                self.orderInfo.toPlace = "Быстрый заказ"
                self.orderInfo.price = 0
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
        Networking.instanse.createOrder(orderInfo) { [weak self]  result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
                self?.enableMenu()
                self?.navigationController?.popViewControllerAnimated(true)
            case .Response(let orderID):
                self?.orderInfo.orderID = orderID
                self?.cancelRequestButton.enabled = true
                self?.radarView.startAnimation()
                if ((self?.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self!, selector: "monitorOrderStatus", userInfo: nil, repeats: true)) != nil) {
                    self?.timer!.fire()
                }
            }
        }
    }
    
    
    func monitorOrderStatus() {
        Networking.instanse.checkOrder(orderInfo) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let orders):
//                debugPrint(orderStatus)
                guard let orderStatus = orders.first?.orderStatus else { return }
                switch orderStatus {
                case 1:
                    self?.timer?.invalidate()
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    guard let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue) as? MyOrders else {
                        return
                    }
                    contr.selectedOrder = self?.orderInfo
                    self?.enableMenu()
                    let nav = NavigationContr(rootViewController: contr)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                case 3:
                    Popup.instanse.showInfo("Внимание", message: "Ваш заказ отменен")
                    self?.enableMenu()
                    self?.navigationController?.popViewControllerAnimated(true)
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func cancelTouched() {
        Networking.instanse.cancelOrder(orderInfo) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                self?.timer?.invalidate()
                self?.enableMenu()
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

}






