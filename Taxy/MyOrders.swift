//
//  MyOrders.swift
//  Taxy
//
//  Created by iosdev on 26.11.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//


// TODO  отображать у заказа значок, если заказ принят текущим водителем и сделать контроллер с только моими заказами
import Foundation
import UIKit
import BTNavigationDropdownMenu
import DrawerController


class MyOrders: UITableViewController, SegueHandlerType {
    
    var orders = [Order]()
    var selectedOrderId: String?
    enum SegueIdentifier: String {
        case ShowOrderDetailsSegue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        setupMenuButtons()
        loadOrders(0)        
        if UserProfile.sharedInstance.type == .Passenger {
            self.title = "Заказы"
            
            if let selectedOrder = selectedOrderId {
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: selectedOrder)
            }
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowOrderDetailsSegue:
            if let contr = segue.destinationViewController as? OrderInfoVC, orderId = sender as? String {
                contr.orderId = orderId
            }
        }
    }
}


extension MyOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let order = orders[indexPath.row]

        if UserProfile.sharedInstance.type == .Passenger {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("passengerOrderCell", forIndexPath: indexPath) as! passengerOrderCell
            cell.configureViewWithOrder(order)
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("driverOrderCell", forIndexPath: indexPath) as! driverOrderCell
            cell.configureViewWithOrder(order)
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let order = orders[indexPath.row]
        switch UserProfile.sharedInstance.type {
        case .Passenger:
            if order.orderStatus == 1 {
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order.orderID)
            }
        case .Driver:
            if order.orderStatus == 1 && order.driverInfo?.userID == UserProfile.sharedInstance.userID {
                // заказ принят и принят этим водителем
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order.orderID)
            }
        }
    }
    
    
}


class driverOrderCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var passengerIdLabel: UILabel!
    @IBOutlet weak var passengerPhoneLabel: UILabel!
    @IBOutlet weak var passengerNameLabel: UILabel!
    @IBOutlet weak var fromPlaceLabel: UILabel!
    @IBOutlet weak var toPlaceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configureViewWithOrder(order: Order) {
        if let price = order.price {
            priceLabel.text = String(price) + "р"
        }
        passengerNameLabel.text = "имя пассажира"
        
        if let fromPlace = order.fromPlace {
            fromPlaceLabel.text = fromPlace
        }
        if let toPlace = order.toPlace {
            toPlaceLabel.text = toPlace
        }
        
        if let userId = order.userID {
            passengerIdLabel.text = "user ID: " + userId
        }
        
        if let orderId = order.orderID {
            idLabel.text = "order ID: " + orderId
        }
    }
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
        
        statusView.layer.cornerRadius = statusView.frame.size.width / 2
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