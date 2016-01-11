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
    case Menu
    case Other
}



class MenuVC: ExampleViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    let drawerWidths: [CGFloat] = [160, 200, 240, 280, 320]
    let ordersSection = ["Быстрый заказ", "Создать заказ", "Мои заказы"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        
        self.tableView.backgroundColor = UIColor(red: 110 / 255, green: 113 / 255, blue: 115 / 255, alpha: 1.0)
        self.tableView.separatorStyle = .None
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 161 / 255, green: 164 / 255, blue: 166 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 55 / 255, green: 70 / 255, blue: 77 / 255, alpha: 1.0)]
        
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // See https://github.com/sascha/DrawerController/issues/12
        self.navigationController?.view.setNeedsLayout()
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: self.tableView.numberOfSections - 1)), withRowAnimation: .None)
        
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
        case DrawerSection.Menu.rawValue:
            return 1
        case DrawerSection.Avatar.rawValue:
            return 1
        case DrawerSection.Orders.rawValue:
            return ordersSection.count
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
                cell.imageView?.image = UserProfile().image
                cell.textLabel?.text = "Профиль"
          
            case DrawerSection.Orders.rawValue:
//                switch indexPath.row {
//                case 0:
                    cell.textLabel?.text = ordersSection[indexPath.row]
//                case 1:
//                    cell.textLabel?.text = ordersSection[1]
//                case 2:
//                    cell.textLabel?.text = ordersSection[2]
//                default:
//                    break
//                }
            
            case DrawerSection.Menu.rawValue:
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
        case DrawerSection.Menu.rawValue:
            return "Общее"
        case DrawerSection.Orders.rawValue:
            return "Заказы"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case DrawerSection.Menu.rawValue, DrawerSection.Orders.rawValue:
            let headerView = SideDrawerSectionHeaderView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.bounds), height: 30.0))
            headerView.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
            headerView.title = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        switch indexPath.section {
//        case DrawerSection.Menu.rawValue:
//            switch indexPath.row {
//
//            case 0:
//                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue)
//                let nav = NavigationContr(rootViewController: contr)
//                self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
//                
//            default:
//                break
//        }
        
            
        case DrawerSection.Avatar.rawValue:
            if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MySettingsSTID.rawValue) as? MyProfileVC {
                contr.isRegistration = false
                let nav = NavigationContr(rootViewController: contr)
                self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            } else {
                print("MySettingsSTID doesnt match MyProfileVC")
            }
            
       
         
            
        case DrawerSection.Orders.rawValue:
            switch indexPath.row {
                
            case 0:
                 let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.TaxyRequestingSTID.rawValue)
                 let nav = NavigationContr(rootViewController: contr)
                 self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)

            case 1:
                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue)
                let nav = NavigationContr(rootViewController: contr)
                self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                
            case 2:
                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MyOrdersSTID.rawValue)
                let nav = NavigationContr(rootViewController: contr)
                self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            default:
                break
            }
            
        case DrawerSection.Other.rawValue:
            switch indexPath.row {
            case 0:
                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.RulesSTID.rawValue)
                let nav = NavigationContr(rootViewController: contr)
                self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            default:
                break
            }
       
        default:
            break
        }
        
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}