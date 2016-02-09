//
//  MakeOrderVC.swift
//  Taxy
//
//  Created by Artem Valiev on 05.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit
import Former
import DrawerController
import SwiftLocation


final class MakeOrderVC: FormViewController {
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    var fromRow:TextViewRowFormer<FormTextViewCell>?
    var toRow:TextViewRowFormer<FormTextViewCell>?
    var priceRow:TextFieldRowFormer<ProfileFieldCell>?
    
    var orderInfo = Order()
    
    private lazy var informationSection: SectionFormer = {
        let childChairRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Детское кресло?"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = UIFont.bold_Med()
            $0.switchButton.onTintColor = .formerSubColor()
            }.configure {
                $0.switchWhenSelected = true
            }.onSwitchChanged { [weak self] in
                self?.orderInfo.isChildChair = $0
        }
        /////////// comment ////////////
        let commentRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = UIFont.light_Small()
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Ваш комментарий к заказу"
            }.onTextChanged {
                self.orderInfo.comment = $0
        }
        ////////////////////////////////
        
        return SectionFormer(rowFormer:commentRow, childChairRow)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заказать"
        setupMenuButtons()
        configure()
    }
    
    deinit {
        print("\(__FUNCTION__)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    func setupMenuButtons() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: true)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func configure() {
        
        
        
        
        ////////// from place /////////////
        let fromRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = UIFont.light_Med()
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            $0.textLabel?.font = UIFont.light_Small()
            
            }.configure {
                $0.placeholder = "Откуда?"
                $0.text = orderInfo.fromPlace
                $0.rowHeight = 44
            }.onTextChanged { [weak self] text in
                self?.orderInfo.fromPlace = text
                self?.orderInfo.fromPlaceCoordinates = nil
        }
        
        
        
        let buttons2Row = ButtonsRowFormer<TwoButtonsCell>(instantiateType: .Nib(nibName: "TwoButtonsCell"))
            .configure {
                $0.rowHeight = 40
            }
            .onButtonPressed { [weak self] index in
                switch index {
                case 0:
                    Helper().getAddres({ [weak self] (address, coords) -> Void in
                        self?.orderInfo.fromPlace = address
                        self?.orderInfo.fromPlaceCoordinates = coords
                        self?.update()
                        }, failure: { (error) -> Void in
                            Popup.instanse.showError("Ошибка", message: error)
                    })
                case 1:
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                        contr.initiator = NSStringFromClass((self?.dynamicType)!)
                        contr.onSelected = {
                            self?.orderInfo.fromPlace = $0.address
                            self?.orderInfo.fromPlaceCoordinates = $0.coords
                        }
                        self?.navigationController?.pushViewController(contr, animated: true)
                    }
                default:
                    break
                }
        }
        
        
        
        self.fromRow = fromRow
        //////////////////////////////
        
        
        ////////// to place /////////////
        let toRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = UIFont.light_Med()
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            $0.textLabel?.font = UIFont.light_Small()
            }.configure {
                $0.placeholder = "Куда?"
                $0.text = orderInfo.toPlace
                $0.rowHeight = 44
            }.onTextChanged { [weak self] text in
                self?.orderInfo.toPlace = text
        }
        
        
        let findOnMapRow = ButtonsRowFormer<TwoButtonsCell>(instantiateType: .Nib(nibName: "OneButtonCell"))
            .configure {
                $0.rowHeight = 40
            }
            .onButtonPressed { [weak self] index in
                self?.former.deselect(false)
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                    contr.initiator = String(MakeOrderVC)// NSStringFromClass((self?.dynamicType)!)
                    contr.onSelected = {
                        self?.orderInfo.toPlace = $0.address
                    }
                    self?.navigationController?.pushViewController(contr, animated: true)
                }
        }
        
        
        
        self.toRow = toRow
        //////////////////////////////
        
        
        ///////////price//////////////
        let priceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.textLabel?.font = UIFont.light_Small()
            $0.titleLabel.text = "Цена"
            $0.textField.keyboardType = .DecimalPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Введите цену"
                if let price = orderInfo.price {
                    $0.text = String(price)
                }
            }.onTextChanged { [weak self] price in
                self?.orderInfo.price = Int(price)
        }
        
        self.priceRow = priceRow
        //////////////////////////////
        
        
        
        
        
        let moreRow = SwitchRowFormer<FormSwitchCell>() {
            $0.textLabel?.font = UIFont.light_Small()
            $0.titleLabel.text = "Дополнительная информация"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.switchButton.onTintColor = .formerSubColor()
            }.configure {
                $0.switched = orderInfo.moreInformation
                $0.switchWhenSelected = true
            }.onSwitchChanged { [weak self] in
                self?.orderInfo.moreInformation = $0
                self?.switchInfomationSection()
                
        }
        
        
        
        let makeOrderButtonRow = LabelRowFormer<CenterLabelCell>() {
            $0.backgroundColor = .mainOrangeColor()
            $0.titleLabel.textColor = .whiteColor()
            }
            .configure {
                $0.text = "Создать заказ"
            }
            .onSelected { [weak self] _ in
                self?.former.deselect(true)
                guard let order = self?.orderInfo else {return}
                self?.createOrder(order)
        }
        
        
        let titleRow = LabelRowFormer<CenterLabelCell>() { [weak self] in
            let orderType = self?.orderInfo.orderType.title() ?? ""
            $0.textLabel?.text = "\(orderType)"
            $0.textLabel?.textAlignment = .Center
            $0.textLabel?.font = UIFont.light_Lar()
            }.configure {
                $0.rowHeight = 40
            }
            .onSelected { [weak self] _ in
                self?.former.deselect(false)
        }
        
        let titleSection = SectionFormer(rowFormer: titleRow)
        let fromSection = SectionFormer(rowFormer: fromRow, buttons2Row)
        let toSection = SectionFormer(rowFormer: toRow, findOnMapRow)
        let priceSection = SectionFormer(rowFormer: priceRow)
        let moreSection = SectionFormer(rowFormer: moreRow)
        let buttonSection = SectionFormer(rowFormer: makeOrderButtonRow)
        
        former.append(sectionFormer:titleSection, fromSection, toSection, priceSection, moreSection, buttonSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        
    }
    
    
    func update() {
        toRow?.configure {
            $0.text = orderInfo.toPlace
        }
        fromRow?.configure {
            $0.text = orderInfo.fromPlace
        }
        priceRow?.configure {
            if let price = orderInfo.price {
                $0.text = String(price)
            }
        }
        
        toRow?.update()
        fromRow?.update()
        priceRow?.update()
    }
    
    
    
    private func switchInfomationSection() {
        if orderInfo.moreInformation {
            former.insertUpdate(sectionFormer: informationSection, toSection: former.numberOfSections - 1, rowAnimation: .Top)
        } else {
            former.removeUpdate(sectionFormer: informationSection, rowAnimation: .Top)
        }
    }
    
//    private func createOrder(order: Order = Order()) {
//        Helper().showLoading("Создание заказа")
//        Networking.instanse.createOrder(order) { [weak self]  result in
//            Helper().hideLoading()
//            switch result {
//            case .Error(let error):
//                Popup.instanse.showError("Не удалось создать заказ", message: error)
//            case .Response(let orderID):
//                self?.instantiateSTID(STID.MyOrdersSTID)
//            }
//        }
//    }
    
}