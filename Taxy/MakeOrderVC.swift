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

//enum orderType: Int {
//    case Город
//    case Межгород
//    case Грузовое
//}

//{ City, Intercity, Freight, Service }


class MakeOrderVC: FormViewController {
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    var fromRow:TextViewRowFormer<FormTextViewCell>?
    var toRow:TextViewRowFormer<FormTextViewCell>?
    var orderInfo = Order()
    var fastOrder = false
    
    private lazy var informationSection: SectionFormer = {
        let childChairRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Детское кресло?"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.switchButton.onTintColor = .formerSubColor()
            }.configure {
                $0.switchWhenSelected = true
            }.onSwitchChanged { [weak self] in
                self?.orderInfo.isChildChair = $0
        }
        /////////// comment ////////////
        let commentRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
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
        setupMenuButtons()
        configure()
        if fastOrder == true {
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.TaxyRequestingSTID.rawValue)
            self.navigationController?.pushViewController(contr, animated: true)
        }
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
        
        let doneButton = UIBarButtonItem(title: "Создать заказ", style: .Plain, target: self, action: "orderTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func configure() {
        

        
        
        ////////// from place /////////////
        let fromRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 13)

            }.configure {
                $0.placeholder = "Откуда?"
                $0.text = orderInfo.fromPlace
                $0.rowHeight = 44
            }.onTextChanged {
                self.orderInfo.fromPlace = $0
        }
        

        
        let buttons2Row = ButtonsRowFormer<TwoButtonsCell>(instantiateType: .Nib(nibName: "TwoButtonsCell"))
            .configure {
                $0.rowHeight = 30
            }
            .onButtonPressed { [weak self] index in
                switch index {
                case 0:
                Helper().getAddres {
                    self?.orderInfo.fromPlace = $0.0
                    self?.orderInfo.coordinates = $0.1
                    self?.update()
                    }
                case 1:
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                        contr.initiator = NSStringFromClass((self?.dynamicType)!)
                        contr.onSelected = {
                            self?.orderInfo.fromPlace = $0.address
                            self?.orderInfo.coordinates = $0.coords
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
            $0.textView.font = .systemFontOfSize(15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 13)
            }.configure {
                $0.placeholder = "Куда?"
                $0.text = orderInfo.toPlace
                $0.rowHeight = 44
            }.onTextChanged {
                self.orderInfo.toPlace = $0
        }
        
        let findOnMapRow = LabelRowFormer<CenterLabelCell>() {
            $0.textLabel?.text = "Найти на карте"
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 13)
            }
            .onSelected { [weak self] _ in
                self?.former.deselect(false)
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                    contr.initiator = NSStringFromClass((self?.dynamicType)!)
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
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 13)
            $0.titleLabel.text = "Цена"
            $0.textField.keyboardType = .DecimalPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Введите цену"
                $0.text = String(300)
            }.onTextChanged {
                self.orderInfo.price = Int($0)
        }
        //////////////////////////////
        
        
      
        
        
        let moreRow = SwitchRowFormer<FormSwitchCell>() {
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 14)
            $0.titleLabel.text = "Дополнительная информация"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.switchButton.onTintColor = .formerSubColor()
            }.configure {
                $0.switched = orderInfo.moreInformation
                $0.switchWhenSelected = true
            }.onSwitchChanged { [weak self] in
                self?.orderInfo.moreInformation = $0
                //                if !$0 {
                //                    self?.orderInfo.isChildChair = false
                //                }
                self?.switchInfomationSection()
                
        }
        
        
        
//        let createHeader: (String -> ViewFormer) = { text in
//            return LabelViewFormer<FormLabelHeaderView>()
//                .configure {
//                    $0.text = text
//                    $0.viewHeight = 44
//            }
//        }

        let titleRow = LabelRowFormer<CenterLabelCell>() {
            $0.textLabel?.text = "Создать заказ \(self.orderInfo.orderType.title())"
            $0.textLabel?.textAlignment = .Center
            $0.textLabel?.font = UIFont(name: "Helvetica Light", size: 18)
            }.configure {
                $0.rowHeight = 40
            }
            .onSelected { [weak self] _ in
                self?.former.deselect(false)
        }
    
        
//        let segmentSection = SectionFormer(rowFormer: taxyTypeRow)
        let fromSection = SectionFormer(rowFormer:titleRow, fromRow, buttons2Row)
//            .set(headerViewFormer: createHeader("Создать заказ \(orderInfo.orderType.title())"))
        let toSection = SectionFormer(rowFormer: toRow, findOnMapRow)
//            .set(headerViewFormer: createHeader("Куда"))
        let priceSection = SectionFormer(rowFormer: priceRow)
//        let commentSection = SectionFormer(rowFormer: commentRow)
        let moreSection = SectionFormer(rowFormer: moreRow)
        
        
        former.append(sectionFormer: fromSection, toSection, priceSection, moreSection)
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
        
        toRow?.update()
        fromRow?.update()
    }
    
    
    func orderTouched() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.TaxyRequestingSTID.rawValue) as? TaxyRequestingVC {
            contr.orderInfo = orderInfo
            self.navigationController?.pushViewController(contr, animated: true)
        }
    }
    
    
    private func switchInfomationSection() {
        if orderInfo.moreInformation {
            former.insertUpdate(sectionFormer: informationSection, toSection: former.numberOfSections, rowAnimation: .Top)
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: informationSection.numberOfRows - 1, inSection: former.numberOfSections - 1), atScrollPosition: .Bottom, animated: true)
        } else {
            former.removeUpdate(sectionFormer: informationSection, rowAnimation: .Top)
        }
    }
    
}