//
//  EnterPhoneVC.swift
//  Taxy
//
//  Created by iosdev on 27.11.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit
import DrawerController
import Former

enum RowType: Int {
    case Phone
    case Pincode
}


final class LoginViewController: UIViewController {
    
    // MARK: Public
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Добро пожаловать!"
        tableView.separatorStyle = .None
        self.evo_drawerController?.leftDrawerViewController = nil
        switchInfomationSection(.Phone)
        configure()
        updateView()
//goAhead()
        
    }
    
    
    // MARK: Private
    private var loginInfo = Login()
    private lazy var former: Former = Former(tableView: self.tableView)
    private var getSmsButtonRow: LabelRowFormer<CenterLabelCell>?
    
    @IBOutlet private weak var tableView: UITableView!
//    @IBOutlet private weak var dimmingView: UIControl!
    
   
    private lazy var phoneSection: SectionFormer = {
        
        let descriptionHeader = LabelViewFormer<FormLabelHeaderView>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .whiteColor()
            }.configure {
                $0.viewHeight = 40
                $0.text = "Добро пожаловать!"
                $0.textAligment = .Center
        }
        
        let phoneRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFontOfSize(15)
            $0.textField.keyboardType = .DecimalPad
            }.configure {
                $0.placeholder = "Номер телефона"
                $0.text = self.loginInfo.phone
            }.onTextChanged { [weak self] in
                self?.loginInfo.phone = $0
                self?.updateView()
        }
        return SectionFormer(rowFormer: phoneRow).set(headerViewFormer: descriptionHeader)
    }()
    
    
    private lazy var pincodeSection: SectionFormer = {
        
        let descriptionHeader = LabelViewFormer<FormLabelHeaderView>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .whiteColor()
            }.configure {
                $0.viewHeight = 50
        }
        
        
        let pincodeRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "СМС код"
            $0.textField.keyboardType = .DecimalPad
            }.configure {
                $0.placeholder = "Введите код"
            }.onTextChanged { [weak self] in
                self?.loginInfo.pincode = $0
                self?.updateView()
        }
        
        return SectionFormer(rowFormer: pincodeRow).set(headerViewFormer: descriptionHeader)
    }()
    
    
    private lazy var noSMSSection: SectionFormer = {
        let phoneRow = LabelRowFormer<CenterLabelCell>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .whiteColor()
            $0.selectionStyle = .None
        }.configure {
            $0.text = "Не пришло СМС?"
            }.onSelected { [weak self] _ in
                if let phone = self?.loginInfo.phone {
                    Popup.instanse.showQuestion(phone, message: "Отправить СМС заново?", otherButtons: ["Отмена"]).handler { selectedIndex in
                        if selectedIndex == 0 {
                            Networking.instanse.getSms(self?.loginInfo) { [weak self] result in
                                switch result {
                                case .Error(let error):
                                    Popup.instanse.showError("", message: error)
                                case .Response(let data):
                                    self?.loginInfo.id = data
                                }
                                
                            }
                        }
                    }
                }
        }
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>() {
                $0.contentView.backgroundColor = .clearColor()
                }.configure {
                    $0.viewHeight = 30
            }
        }
        return SectionFormer(rowFormer: phoneRow).set(headerViewFormer: createSpaceHeader())
    }()
    
    
    private func configure() {
        tableView.backgroundColor = .formerColor()
        tableView.layer.cornerRadius = 5
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        
        
        
        let getSmsButtonRow = LabelRowFormer<CenterLabelCell>()
            .onSelected { [weak self] _ in
                
            if self?.former.firstSectionFormer === self?.phoneSection {
                
                if let phone = self?.loginInfo.phone {
                    self?.view.endEditing(true)
                    Popup.instanse.showQuestion(phone, message: "Отправить СМС на указанный номер?", otherButtons: ["Отмена"]).handler { selectedIndex in
                        if selectedIndex == 0 {
                            Networking().getSms(self?.loginInfo) { [weak self] result in
                                
                                switch result {
                                case .Error(let error):
                                    Popup.instanse.showError("", message: error)
                                    // TODO hide loading
                                case .Response(let data):
                                    self?.loginInfo.id = data
                                    self?.switchInfomationSection(.Pincode)
                                    self?.updateView()
                                }
                            }
                        }
                    }
                }
            } else {
                Networking().checkPincode(self?.loginInfo) { [weak self] result in
                    
                    switch result {
                    case .Error(let error):
                        Popup.instanse.showError("", message: error)
                    case .Response(let data):
                        LocalData.instanse.saveUserID(data)
                        self?.goAhead()
                    }
                    
                }
            }
        }
        
        self.getSmsButtonRow = getSmsButtonRow
        
        let createSpaceHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>() {
                $0.contentView.backgroundColor = .clearColor()
                }.configure {
                    $0.viewHeight = 30
            }
        }
        let buttonSection = SectionFormer(rowFormer: getSmsButtonRow)
            .set(headerViewFormer: createSpaceHeader())
        
        former.append(sectionFormer: buttonSection)
    }
    
    
    
    private func updateView() {
        if former.firstSectionFormer === phoneSection {
            if let row = phoneSection.firstRowFormer as? TextFieldRowFormer<FormTextFieldCell> {
                let enabled = !(row.text?.isEmpty ?? true)
                getSmsButtonRow?.enabled = enabled
            }
            getSmsButtonRow?.text = "Получить СМС"
            getSmsButtonRow?.update()
        } else {
            if let row = pincodeSection.firstRowFormer as? TextFieldRowFormer<ProfileFieldCell> {
                let enabled = !(row.text?.isEmpty ?? true)
                getSmsButtonRow?.enabled = enabled
            }
            getSmsButtonRow?.text = "Отправить код"
            getSmsButtonRow?.update()
        }
        
//        if let pincodeRow = pincodeSection.firstRowFormer as? TextFieldRowFormer<ProfileFieldCell> {
//            pincodeRow.update()
//        }
    }
    
    
    
    private func switchInfomationSection(currentRow: RowType) {
        switch currentRow {
        case .Phone:
            former.insertUpdate(sectionFormer: phoneSection, toSection: 0, rowAnimation: .Top)
            former.removeUpdate(sectionFormer: pincodeSection)
            former.removeUpdate(sectionFormer: noSMSSection)
        
        case .Pincode:
            former.insertUpdate(sectionFormer: pincodeSection, toSection: 0, rowAnimation: .Top)
            former.insertUpdate(sectionFormer: noSMSSection, toSection: former.numberOfSections)
            former.removeUpdate(sectionFormer: phoneSection)
        }
    }
    
    
    private func goAhead() -> Void {
//        let vc = MenuVC()
//        let navC = UINavigationController(rootViewController: vc)
//        self.evo_drawerController?.leftDrawerViewController = navC
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MySettingsSTID.rawValue)
        let nav = NavigationContr(rootViewController: contr)
        self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
    }
}
