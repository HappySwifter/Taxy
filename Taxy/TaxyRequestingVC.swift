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

class TaxyRequestingVC: UIViewController, SegueHandlerType {
    
    @IBOutlet weak var radarView: CCMRadarView!
    @IBOutlet weak var cancelRequestButton: UIButton!
    var orderInfo: Order?
    var timer: NSTimer?
    
    enum SegueIdentifier: String {
        case ShowOrderDetailsSegue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        title = "Поиск такси"
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
                self?.navigationController?.popViewControllerAnimated(true)
            case .Response(let orderID):
                self?.orderInfo?.orderID = orderID
                self?.cancelRequestButton.enabled = true
//                Helper().showLoading("Поиск водителя")
                self?.radarView.startAnimation()
                if ((self?.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self!, selector: "monitorOrderStatus", userInfo: nil, repeats: true)) != nil) {
                    self?.timer!.fire()
                }
            }
        }
    }
    
    
    func monitorOrderStatus() {
        Networking.instanse.monitorOrderStatus(orderInfo!) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let orderStatus):
                debugPrint(orderStatus)
                switch orderStatus {
                case 1:
                    self?.timer?.invalidate()
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    guard let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue) as? MyOrders else {
                        return
                    }
                    contr.selectedOrderId = self?.orderInfo?.orderID
                    let nav = NavigationContr(rootViewController: contr)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                    
//                    self?.performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: self?.orderInfo!)
                default:
                    break
                }
            }
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segueIdentifierForSegue(segue) {
//        case .ShowOrderDetailsSegue:
//            if let contr = segue.destinationViewController as? OrderInfoVC {
//                
//            }
//        }
//    }
    
    @IBAction func cancelTouched() {
        Networking.instanse.cancelOrder(orderInfo!) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

}






