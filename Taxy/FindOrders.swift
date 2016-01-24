//
//  FindOrders.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import BTNavigationDropdownMenu
import CNPPopupController

class FindOrders: UITableViewController {
    
    var timer: NSTimer?
    var mainOrdersTimer: NSTimer?
    var selectedType: Int = 1
    var orders = [Order]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let items = OrderType.value().map { element in element.title() }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items.first!, items: items)
        self.navigationItem.titleView = menuView
        menuView.didSelectItemAtIndexHandler = { [weak self] indexPath in
            self?.selectedType = indexPath + 1
            self?.loadOrders()
        }
    }
    
    deinit {
        debugPrint("\(__FUNCTION__) in \(__FILE__)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "getOnlyMyOrder", userInfo: nil, repeats: true)
        timer!.fire()
        
        mainOrdersTimer?.invalidate()
        mainOrdersTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "loadOrders", userInfo: nil, repeats: true)
        mainOrdersTimer!.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        mainOrdersTimer?.invalidate()
    }
    
    func loadOrders() {
        Networking.instanse.getOrders(selectedType, find: true) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let data):
                self?.orders = data
                self?.tableView.reloadData()
            }
        }
    }
    
    
    func getOnlyMyOrder() {
        Networking.instanse.getOnlyMyOrder { [weak self] result in
            switch result {
            case .Error(let error):
                debugPrint(error)
            case .Response(let orders):
                Helper().canAcceptOrder() { can in
                    if can {
                        self?.presentPersonalOrderDialog(orders)
                    } else {
                        debugPrint("cant accept personal order. Already has one opened")
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
                }
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
            if order.orderStatus == 0 {
                Helper().showLoading("Загрузка...")
                Helper().canAcceptOrder() { [weak self] can in
                    Helper().hideLoading()
                    if can {
                        self?.acceptOrder(order)
                    } else {
                        Popup.instanse.showInfo("Внимание", message: "У вас уже есть активный заказ")
                    }
                }
        }
    }
    
}


extension FindOrders {
    
    func presentPersonalOrderDialog(data: [Order]) {
        
        guard let order = data.first, let fromPlace = order.fromPlace, let toPlace = order.toPlace, let price = order.price, let id = order.orderID else { debugPrint("cant show personal order")
            return
        }
        var popupController = CNPPopupController()
        let dismissButton = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 45))
        dismissButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dismissButton.titleLabel?.font = .bold_Lar()
        dismissButton.setTitle("Отменить", forState: UIControlState.Normal)
        dismissButton.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        dismissButton.layer.cornerRadius = 4;
        dismissButton.selectionHandler = { _ in
            Networking.instanse.rejectOrder(id)
            popupController.dismissPopupControllerAnimated(true)
        }
        
        let acceptButton = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 45))
        acceptButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        acceptButton.titleLabel?.font = .bold_Lar()
        acceptButton.setTitle("Принять", forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        acceptButton.layer.cornerRadius = 4;
        acceptButton.selectionHandler = { [weak self] _ in
            popupController.dismissPopupControllerAnimated(true)
            self?.acceptOrder(order)
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.text = "Персональный заказ"
        titleLabel.font = .bold_Lar()
        titleLabel.textAlignment = .Center
        
        let priceLabel = UILabel()
        priceLabel.numberOfLines = 0
        priceLabel.text = "\(price) руб."
        priceLabel.font = .bold_Lar()
        priceLabel.textAlignment = .Center
        priceLabel.textColor = .mainOrangeColor()

        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.text = fromPlace
        lineOneLabel.font = .light_Med()
        lineOneLabel.textAlignment = .Left
        
        let lineTwoLabel = UILabel()
        lineTwoLabel.numberOfLines = 0;
        lineTwoLabel.text = toPlace
        lineTwoLabel.font = .light_Med()
        lineTwoLabel.textAlignment = .Left
        
        popupController = CNPPopupController(contents:[titleLabel, priceLabel, lineOneLabel, lineTwoLabel, dismissButton, acceptButton])
        popupController.theme = CNPPopupTheme.defaultTheme()
        popupController.theme.popupStyle = CNPPopupStyle.Centered
        popupController.theme.shouldDismissOnBackgroundTouch = false
        popupController.presentPopupControllerAnimated(true)
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