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

final class TaxyRequestingVC: UIViewController {
    
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
            
            Helper().getAddres({ [weak self] (addres, location) -> Void in
                
                self?.orderInfo.fromPlace = addres
                self?.orderInfo.fromPlaceCoordinates = location
                self?.orderInfo.toPlace = "Быстрый заказ"
                self?.orderInfo.price = 0
                self?.createOrder()
                
                }, failure: { [weak self] (error) -> Void in
                    Popup.instanse.showError("Ошибка", message: error)
                    self?.dismiss()
            })

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
        Loading.stop()
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
//                self?.radarView.startAnimation()
                self?.radarView.hidden = true
                self?.view.backgroundColor = UIColor.whiteColor()//(patternImage: UIImage(named: "loaging_image.jpg")!)
//                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//                blur.frame = (self?.view.bounds)!
//                blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//                self?.view.addSubview(blur)
                
                self?.view.addSubview(Loading.indicator)
                Loading.start()
                
                
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
                guard let order = orders.first, let orderStatus = order.orderStatus else { return }
                switch orderStatus {
                case 1:
                    self?.timer?.invalidate()
                    self?.enableMenu()

                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue)
                    let nav = NavigationContr(rootViewController: contr)
                    
                    let orderInfoVC = storyBoard.instantiateViewControllerWithIdentifier(STID.OrderInfoSTID.rawValue) as! OrderInfoVC
                    orderInfoVC.order = order
                    nav.viewControllers.insert(orderInfoVC, atIndex: nav.viewControllers.count)
                    
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
        Helper().showLoading("Отменяю заказ")
        Networking.instanse.cancelOrder(orderInfo) { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            default:
                break
            }
            self?.dismiss()
        }
    }
    
    func dismiss() {
        timer?.invalidate()
        enableMenu()
        navigationController?.popViewControllerAnimated(true)
    }

}






