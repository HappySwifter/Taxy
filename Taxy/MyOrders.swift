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


final class MyOrders: UITableViewController, SegueHandlerType, NoOrdersCellDelegate {
    
    var orders = [Order]()
    var timer: NSTimer?

    enum SegueIdentifier: String {
        case ShowOrderDetailsSegue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        setupMenuButtons()
        self.title = "Мои заказы"

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "loadOrders", userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    deinit {
        debugPrint("\(__FUNCTION__): \(__FILE__)")
    }

    
    func refresh(control: UIRefreshControl) {
        control.endRefreshing()
        loadOrders()
    }
    
    
    func loadOrders() {
        Networking.instanse.getOrders(0) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
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
            guard let row = sender as? Int, let contr = segue.destinationViewController as? OrderInfoVC else {
                debugPrint("\(__FUNCTION__) - error")
                return }
            contr.order = orders[row]
        }
    }
}


extension MyOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if orders.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(NoOrdersCell), forIndexPath: indexPath) as! NoOrdersCell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            cell.configureForVC(String(MyOrders))
            cell.delegate = self
            return cell
        } else {
            let order = orders[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier(String(passengerOrderCell), forIndexPath: indexPath) as! passengerOrderCell
            cell.separatorInset = UIEdgeInsetsZero
            cell.configureViewWithOrder(order)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orders.count > 0 {
            return orders.count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if orders.count > 0 {
            return 132
        } else {
            return 210
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard orders.count > 0 else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let order = orders[indexPath.row]
        switch UserProfile.sharedInstance.type {
        case .Passenger:
            if order.orderStatus == 1 {
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: indexPath.row)
            }
        case .Driver:
            if order.orderStatus == 1 && order.driverInfo.userID == UserProfile.sharedInstance.userID {
                // заказ принят и принят этим водителем
                performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: indexPath.row)
            }
        }
    }
    
    func noOrdersCellButtonTouched() {
        if UserProfile.sharedInstance.type == .Passenger {
            instantiateSTID(STID.MakeOrderSTID)
        } else {
            instantiateSTID(STID.FindOrdersSTID)
        }
    }
    
}





class passengerOrderCell: UITableViewCell {
//    @IBOutlet weak var userIdLabel: UILabel!
//    @IBOutlet weak var idLabel: UILabel!
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
        
   
//        if let userId = order.userID {
//            userIdLabel.text = "user ID: " + userId
//        }
        
//        if let orderId = order.orderID {
//            idLabel.text = "order ID: " + orderId
//        }
        if let createTime = order.createdAt {
            createTimeLabel.text = createTime.stringWithHumanizedTimeDifference(.SuffixAgo, withFullString: false)
        }
    }
    
}