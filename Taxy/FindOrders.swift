//
//  FindOrders.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import BTNavigationDropdownMenu

class FindOrders: UITableViewController, SegueHandlerType {
    
    enum SegueIdentifier: String {
        case ShowOrderDetailsSegue
    }
    var timer: NSTimer?
    var selectedType: Int = 1
    var orders = [Order]()

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
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    guard let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue) as? MyOrders else {
                        return
                    }
                    contr.selectedOrder = order
                    let nav = NavigationContr(rootViewController: contr)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                    
//                    self?.performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order)
                }
            }
        }
    }
    
    
    func loadOrders(type: Int) {
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


extension FindOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let order = orders[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("driverOrderCell", forIndexPath: indexPath) as! driverOrderCell
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

//        if order.orderStatus == 1 && order.driverInfo.userID == UserProfile.sharedInstance.userID {
//            // заказ принят и принят этим водителем
//            performSegueWithIdentifier(.ShowOrderDetailsSegue, sender: order)
//        } else
            if order.orderStatus == 0 {
            acceptOrder(order)
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
    @IBOutlet weak var createTimeLabel: UILabel!
    
    func configureViewWithOrder(order: Order) {
        if let price = order.price {
            priceLabel.text = String(price) + "р"
        }
        if let passName = order.passengerInfo.name {
            passengerNameLabel.text = passName
        }
        
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
        if let createTime = order.createdAt {
            createTimeLabel.text = createTime.stringWithHumanizedTimeDifference(.SuffixAgo, withFullString: false)
        }
    }
}