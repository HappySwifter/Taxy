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
import DrawerController

final class FindOrders: UITableViewController, NoOrdersCellDelegate {
    
    var timer: NSTimer?
    var mainOrdersTimer: NSTimer?
    var selectedType: Int = 1
    var orders = [Order]()
    var popup = CNPPopupController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        setupMenuButtons()
        
        let items = OrderType.value().map { element in element.title() }
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items.first!, items: items)
        self.navigationItem.titleView = menuView
        menuView.didSelectItemAtIndexHandler = { [weak self] indexPath in
            self?.selectedType = indexPath + 1
            self?.loadOrders()
        }
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(DriverFindOrdersPeriod, target: self, selector: "getOnlyMyOrder", userInfo: nil, repeats: true)
        timer!.fire()
        
        mainOrdersTimer?.invalidate()
        mainOrdersTimer = NSTimer.scheduledTimerWithTimeInterval(DriverFindOrdersPeriod, target: self, selector: "loadOrders", userInfo: nil, repeats: true)
        mainOrdersTimer!.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        mainOrdersTimer?.invalidate()
        self.navigationItem.titleView = nil
    }
    
    deinit {
        debugPrint("\(__FUNCTION__) in \(__FILE__)")
    }
    
    func setupMenuButtons() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func refresh(control: UIRefreshControl) {
        control.endRefreshing()
        loadOrders()
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
                guard let order = orders.first else { return }
                Helper().canAcceptOrder() { [weak self] can in
                    if can {
                        self?.presentPersonalOrderDialog(order)
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
            case .Response(let orders):
                
                guard let order = orders.first, let orderStatus = order.orderStatus else { return }
                if orderStatus == 1 {
                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue)
                    let nav = NavigationContr(rootViewController: contr)
                    
                    let orderInfoVC = storyBoard.instantiateViewControllerWithIdentifier(STID.OrderInfoSTID.rawValue) as! OrderInfoVC
                    orderInfoVC.order = order
                    nav.viewControllers.insert(orderInfoVC, atIndex: nav.viewControllers.count)
                    
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                }
            }
        }
    }
}


extension FindOrders {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if orders.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(NoOrdersCell), forIndexPath: indexPath) as! NoOrdersCell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            cell.configureForVC(String(FindOrders))
            cell.delegate = self
            return cell
        } else {
            
            let order = orders[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier("driverOrderCell", forIndexPath: indexPath) as! driverOrderCell
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
            return 160
        } else {
            return 210
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard orders.count > 0 else { return }
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
    
    func noOrdersCellButtonTouched() {
        loadOrders()
    }
    
    


    
}


extension FindOrders {
    
    func presentPersonalOrderDialog(order: Order) {
        
        guard let fromPlace = order.fromPlace, let toPlace = order.toPlace, let price = order.price, let id = order.orderID else { debugPrint("cant show personal order")
            return
        }
        
        popup.dismissPopupControllerAnimated(true)
            
        
        let dismissButton = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 45))
        dismissButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        dismissButton.titleLabel?.font = .bold_Lar()
        dismissButton.setTitle("Отклонить", forState: UIControlState.Normal)
        dismissButton.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        dismissButton.layer.cornerRadius = 4;
        dismissButton.selectionHandler = { [weak self] _ in
            Networking.instanse.rejectOrder(id)
            self?.popup.dismissPopupControllerAnimated(true)
        }
        
        let acceptButton = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 45))
        acceptButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        acceptButton.titleLabel?.font = .bold_Lar()
        acceptButton.setTitle("Принять", forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        acceptButton.layer.cornerRadius = 4;
        acceptButton.selectionHandler = { [weak self] _ in
            self?.acceptOrder(order)
            self?.popup.dismissPopupControllerAnimated(true)
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
        
        popup = CNPPopupController(contents:[titleLabel, priceLabel, lineOneLabel, lineTwoLabel, dismissButton, acceptButton])
        popup.theme = CNPPopupTheme.defaultTheme()
        popup.theme.popupStyle = CNPPopupStyle.Centered
        popup.theme.presentationStyle = .FadeIn
        popup.theme.shouldDismissOnBackgroundTouch = false
        popup.presentPopupControllerAnimated(true)
    }

}


class driverOrderCell: UITableViewCell {
//    @IBOutlet weak var idLabel: UILabel!
//    @IBOutlet weak var passengerIdLabel: UILabel!
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
//        if let userId = order.userID {
//            passengerIdLabel.text = "user ID: " + userId
//        }
//        if let orderId = order.orderID {
//            idLabel.text = "order ID: " + orderId
//        }
        if let createTime = order.createdAt {
            createTimeLabel.text = createTime.stringWithHumanizedTimeDifference(.SuffixAgo, withFullString: false)
        }
    }
}