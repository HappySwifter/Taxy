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
import DrawerController


class MyOrders: UITableViewController, SegueHandlerType {
    
    var orders = [Order]()
    var selectedOrder: Order?
    enum SegueIdentifier: String {
        case ShowOrderDetailsSegue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        setupMenuButtons()
        loadOrders(0)
        self.title = "Заказы"
        if let selectedOrder = selectedOrder {
            performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: selectedOrder)
        }
    }
    

    
    func refresh(control: UIRefreshControl) {
        control.endRefreshing()
        loadOrders(0)
    }
    
    
    func loadOrders(type: Int) {
        Helper().showLoading("Загрузка заказов")
        Networking.instanse.getOrders(type) { [weak self] result in
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
    
    func acceptOrder(order: Order) {
        guard let orderID = order.orderID else { return }
        Helper().showLoading("Принимаю заказ")
        Networking.instanse.acceptOrder(orderID) { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
                Helper().hideLoading()
            case .Response(let data):
                print(data)
                if data == 1 {
                    self?.performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order)
                }
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
            if let contr = segue.destinationViewController as? OrderInfoVC, order = sender as? Order {
                contr.order = order
            }
        }
    }
}


extension MyOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let order = orders[indexPath.row]

            let cell = self.tableView.dequeueReusableCellWithIdentifier("passengerOrderCell", forIndexPath: indexPath) as! passengerOrderCell
            cell.configureViewWithOrder(order)
            return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 210
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let order = orders[indexPath.row]
        switch UserProfile.sharedInstance.type {
        case .Passenger:
            if order.orderStatus == 1 {
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order)
            }
        case .Driver:
            if order.orderStatus == 1 && order.driverInfo.userID == UserProfile.sharedInstance.userID {
                // заказ принят и принят этим водителем
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order)
            }
//            else if order.orderStatus == 0 {
//                acceptOrder(order)
//            }
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
    @IBOutlet weak var createTimeLabel: UILabel!

    func configureViewWithOrder(order: Order) {
        if let price = order.price {
            priceLabel.text = String(price) + "р"
        }
        if UserProfile.sharedInstance.type == .Driver {
            if let driverName = order.passengerInfo.name, let driverPhone = order.passengerInfo.phoneNumber {
                driverNameLabel.text = driverName + "\n" + driverPhone
            }
        } else {
            if let passName = order.driverInfo.name, let passPhone = order.driverInfo.phoneNumber {
                driverNameLabel.text = passName + "\n" + passPhone
            }
        }
        
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
        if let createTime = order.createdAt {
            createTimeLabel.text = createTime.stringWithHumanizedTimeDifference(.SuffixAgo, withFullString: false)
        }
    }
    
}