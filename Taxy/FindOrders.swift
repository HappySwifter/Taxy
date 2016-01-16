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