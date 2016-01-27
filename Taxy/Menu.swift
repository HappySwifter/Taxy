//
//  SideDrawerViewController..swift
//  Taxy
//
//  Created by iosdev on 26.11.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//


import UIKit
import DrawerController
import MXParallaxHeader

final class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchDelegate {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Дорожное такси"
        navigationController?.navigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "loaging_image_blurred.jpg")!)
        
        // Parallax Header
        self.tableView.parallaxHeader.view = NSBundle.mainBundle().loadNibNamed("RocketHeader", owner: self, options: nil).first as? UIView
        self.tableView.parallaxHeader.mode = MXParallaxHeaderMode.Bottom
        
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
    
//    override func contentSizeDidChange(size: String) {
//        self.tableView.reloadData()
//    }
    
   
    
    private func isPassenger() -> Bool {
        return UserProfile.sharedInstance.type == .Passenger
    }
    
    private func getMenuItems() -> [(sectionTitle: String, items: [String])] {
        if isPassenger() {
            return [
                ("", ["Профиль", "Мои заказы"]),
                ("ЗАКАЗАТЬ", ["Быстрый заказ"] + OrderType.value().map { $0.title() })
            ]
        } else {
            return [
                ("", ["Профиль", "Мои заказы"]),
                ("НАЙТИ", ["Поиск заказов"])
            ]
        }
    }
}


extension MenuVC {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return getMenuItems().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMenuItems()[section].items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCell
                cell.configure()
                return cell
            } else if indexPath.row == 1 {
                cell.textLabel?.text = getMenuItems()[section].items[row]
            }
        default:
            cell.textLabel?.text = getMenuItems()[section].items[row]
        }
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getMenuItems()[section].sectionTitle
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let headerView = SwitchHeaderView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(tableView.bounds), height: 40.0))
            headerView.delegate = self
            return headerView
            
        case 1:
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
        case 0:
            if isPassenger() {
                return 0
            } else {
                return 60
            }
        default:
            return 30
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        return 40
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
        cell.contentView.backgroundColor = .clearColor()
//        cell.backgroundView?.backgroundColor = .clearColor()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        switch indexPath.section {
            
            
        case 0:
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
            
        case 1:
            if isPassenger() {
                let makeOrderVC = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue) as! MakeOrderVC
                let nav = NavigationContr(rootViewController: makeOrderVC)
                
                if indexPath.row != 0 {
                    makeOrderVC.orderInfo.orderType = OrderType.value()[indexPath.row - 1]
                } else {
                    // fast order. We're pushing to taxyRequestingVC
                    let taxyRequestingVC = storyBoard.instantiateViewControllerWithIdentifier(STID.TaxyRequestingSTID.rawValue)
                    nav.viewControllers.insert(taxyRequestingVC, atIndex: nav.viewControllers.count)
                }
                evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            } else {
                instantiateSTID(STID.FindOrdersSTID)
            }
        default:
            break
        }
        
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}