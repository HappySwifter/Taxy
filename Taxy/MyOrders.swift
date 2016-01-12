//
//  MyOrders.swift
//  Taxy
//
//  Created by iosdev on 26.11.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit
import BTNavigationDropdownMenu
import DrawerController


class MyOrders: UITableViewController {
    
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        setupMenuButtons()
        loadOrders(0)        
        if UserProfile.sharedInstance.type == .Passenger {
            self.title = "Заказы"
        } else {
            let items = ["По городу", "Межгород", "Грузовое", "Услуги"]
            let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items.first!, items: items)
            self.navigationItem.titleView = menuView
            menuView.didSelectItemAtIndexHandler = { [weak self] indexPath in
                self?.loadOrders(indexPath + 1)
            }
        }
    }
    
    
    func loadOrders(type: Int) {
        Networking.instanse.getOrders(type) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
                // TODO hide loading
            case .Response(let data):
                self?.orders = data
                self?.tableView.reloadData()
            }
        }
    }
    
    
    func setupMenuButtons() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
}


extension MyOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if UserProfile.sharedInstance.type == .Passenger {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("passengerOrderCell", forIndexPath: indexPath) as! passengerOrderCell
            
            let order = orders[indexPath.row]
            cell.configureViewWithOrder(order)
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("driverOrderCell", forIndexPath: indexPath) as! driverOrderCell
            cell.idLabel.text = orders[indexPath.row].orderID
            return cell
            
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
    }
}


class driverOrderCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var fromPlaceLabel: UILabel!
    @IBOutlet weak var toPlaceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
}

class passengerOrderCell: UITableViewCell {
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var orderDetailsLabel: UILabel!
    
    func configureViewWithOrder(order: Order) {
        if let price = order.price {
            priceLabel.text = String(price) + "р"
        }
        driverNameLabel.text = order.driverInfo?.userID
        
        statusView.layer.cornerRadius = 20
        if order.orderStatus == 1 {
            statusView.backgroundColor = UIColor.greenColor()
        } else {
            statusView.backgroundColor = UIColor.redColor()
        }
        
        
        
        var orderDetailsText = ""
        if let fromPlace = order.fromPlace {
            orderDetailsText += fromPlace
        }
        if let toPlace = order.toPlace {
            orderDetailsText += "\n" + toPlace
        }
        orderDetailsLabel.text = orderDetailsText
        
        
        
        
        if let userId = order.userID {
            userIdLabel.text = "user ID: " + userId
        }
        
        if let orderId = order.orderID {
            idLabel.text = "order ID: " + orderId
        }
        
    }
    
}