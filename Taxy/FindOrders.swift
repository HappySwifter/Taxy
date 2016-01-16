//
//  FindOrders.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import BTNavigationDropdownMenu

class FindOrders: MyOrders {
    
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = OrderType.value().map { element in element.title() }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items.first!, items: items)
        self.navigationItem.titleView = menuView
        menuView.didSelectItemAtIndexHandler = { [weak self] indexPath in
            self?.selectedType = indexPath + 1
            self?.loadOrders(indexPath + 1)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "getOnlyMyOrder", userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func getOnlyMyOrder() {
        Networking.instanse.getOnlyMyOrder { result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let data):
                guard let order = data.first, let fromPlace = order.fromPlace, let price = order.price, let id = order.orderID else { return }
                
                let message = fromPlace + "\n" + String(price)
                Popup.instanse.showQuestion("Персональный заказ", message: message, otherButtons: ["Принять"]).handler{ [weak self]
                    index in
                    if index == 0 {
                        Networking.instanse.rejectOrder(id)
                    } else {
                        self?.acceptOrder(order)
                    }
                }
            }
        }
    }
    
    
    override func loadOrders(type: Int) {
        Helper().showLoading("Загрузка заказов")
        Networking.instanse.getOrders(type, find: true) { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let data):
                self?.orders = data
                self?.tableView.reloadData()
            }
        }
    }
}