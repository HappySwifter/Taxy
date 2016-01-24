//
//  SideDrawerViewController..swift
//  Taxy
//
//  Created by iosdev on 26.11.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//


import UIKit
import DrawerController

enum DrawerSection: Int {
    case Avatar
    case Orders
    case Main
    case Other
}



class MenuVC: ExampleViewController, UITableViewDataSource, UITableViewDelegate, SwitchDelegate {
    @IBOutlet weak var tableView: UITableView!
//    let drawerWidths: [CGFloat] = [160, 200, 240, 280, 320]

    let profileSection = ["Профиль", "Мои заказы"]
    let driverOrdersSection = ["Поиск заказов"]
    let passOrdersSection = ["Быстрый заказ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Дорожное такси"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 161 / 255, green: 164 / 255, blue: 166 / 255, alpha: 1.0)
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 55 / 255, green: 70 / 255, blue: 77 / 255, alpha: 1.0)]
    }
    
    func switchChanged(index: Int) {
        Networking.instanse.changeUserState(index) { result in
            switch result {
            case .Response(let index):
                if let state = DriverState(rawValue: index) {
                    UserProfile.sharedInstance.driverState = state
                }
            case .Error(let error):
                debugPrint(error)
          
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // See https://github.com/sascha/DrawerController/issues/12
        self.navigationController?.view.setNeedsLayout()
        
        self.tableView.reloadData()
        
    }
    
    override func contentSizeDidChange(size: String) {
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case DrawerSection.Main.rawValue:
            return 1
        case DrawerSection.Avatar.rawValue:
            if UserProfile.sharedInstance.type == .Passenger {
                return profileSection.count
            } else {
                return profileSection.count
            }
        case DrawerSection.Orders.rawValue:
            if UserProfile.sharedInstance.type == .Passenger {
                return passOrdersSection.count + OrderType.value().count
            } else {
                return driverOrdersSection.count
            }
        case DrawerSection.Other.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell?
        
        if cell == nil {
            cell = SideDrawerTableViewCell(style: .Value1, reuseIdentifier: CellIdentifier)
            cell.selectionStyle = .Blue
        }
        cell.imageView?.image = nil

        
        switch indexPath.section {
            
            case DrawerSection.Avatar.rawValue:
                if indexPath.row == 0 {
                    if let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as? ProfileCell {
                        cell.configure()
                        return cell
                    }
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = profileSection[indexPath.row]
                }
//                else if indexPath.row == 2 {
//                    if let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as? SwitchCell {
//                        cell.configure()
//                        cell.delegate = self
//                        return cell
//                    }
//                }
            
            


            case DrawerSection.Orders.rawValue:
                if UserProfile.sharedInstance.type == .Passenger {
                    if indexPath.row == 0 {
                        cell.textLabel?.text = passOrdersSection[indexPath.row]
                    } else {
                        cell.textLabel?.text = OrderType.value()[indexPath.row - 1].title()
                    }
                } else {
                    cell.textLabel?.text = driverOrdersSection[indexPath.row]
            }
                
            

            case DrawerSection.Main.rawValue:
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Настройки"
               
                default:
                    break
                }
            
        case DrawerSection.Other.rawValue:
            cell.textLabel?.text = "Правила"
            
        default:
            break
        }
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case DrawerSection.Main.rawValue:
            return "Общее"
        case DrawerSection.Orders.rawValue:
            return "Заказы"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case DrawerSection.Avatar.rawValue:
            let headerView = SwitchHeaderView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.bounds), height: 40.0))
            headerView.delegate = self
            return headerView
            
        case DrawerSection.Main.rawValue, DrawerSection.Orders.rawValue:
            let headerView = SideDrawerSectionHeaderView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.bounds), height: 30.0))
            headerView.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
            headerView.title = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case DrawerSection.Avatar.rawValue:
            if isPassenger() {
                return 0
            } else {
                return 60
            }
        case DrawerSection.Orders.rawValue:
            return 30
        case DrawerSection.Main.rawValue:
            return 30
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == DrawerSection.Avatar.rawValue && indexPath.row == 0 {
            return 100
        }
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        switch indexPath.section {

            
        case DrawerSection.Avatar.rawValue:
            switch indexPath.row {
            case 0:
                if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MySettingsSTID.rawValue) as? MyProfileVC {
                    contr.isRegistration = false
                    let nav = NavigationContr(rootViewController: contr)
                    self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                }
            case 1:
                instantiateSTID(STID.MyOrdersSTID)
                
            default:
                break
            }
        
         
            
        case DrawerSection.Orders.rawValue:

            if UserProfile.sharedInstance.type == .Passenger {
                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue) as! MakeOrderVC
                if indexPath.row != 0 {
                    contr.orderInfo.orderType = OrderType.value()[indexPath.row - 1]
                } else {
                    let _ = contr.fastOrder = true
                }
                let nav = NavigationContr(rootViewController: contr)
                evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            } else {
                instantiateSTID(STID.FindOrdersSTID)
//                instantiateVC(FindOrders())
            }
            

            
        case DrawerSection.Other.rawValue:
            switch indexPath.row {
            case 0:
                instantiateSTID(STID.RulesSTID)
            default:
                break
            }
       
        default:
            break
        }
        
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func isPassenger() -> Bool {
        return UserProfile.sharedInstance.type == .Passenger
    }
}