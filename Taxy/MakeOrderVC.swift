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
    
    let orderTypes = ["По городу", "Межгород", "Грузовые"]
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    var fromRow:TextViewRowFormer<FormTextViewCell>?
    var toRow:TextViewRowFormer<FormTextViewCell>?
    var orderInfo = Order()
    
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
        return SectionFormer(rowFormer: childChairRow)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButtons()
        configure()
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
    
    func configure() -> Void {
        
        
        let taxyTypeRow = InlinePickerRowFormer<FormInlinePickerCell, Any>() {
            $0.titleLabel.text = "Тип такси"
            }.configure {
                $0.pickerItems = orderTypes.map { InlinePickerItem(title: $0) }
        }
        
        


////////// from place /////////////
        let fromRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Откуда?"
                $0.text = orderInfo.fromPlace
                $0.rowHeight = 44
            }.onTextChanged {
                self.orderInfo.fromPlace = $0
        }
        
        let getGeoRow = LabelRowFormer<CenterLabelCell>() {
                $0.textLabel?.text = "Отпределить автоматически"
            }
            .onSelected { _ in
                
                Helper().getAddres {
                    self.orderInfo.fromPlace = $0.0
                    self.orderInfo.coordinates = $0.1
                    self.update()
                }
                
//                do {
//                    try SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 20, onSuccess: { (location) -> Void in
//                        print(location)
//                        
//                        if let coord = location?.coordinate {
//                            SwiftLocation.shared.reverseCoordinates(Service.GoogleMaps, coordinates: coord, onSuccess: { (place) -> Void in
//                                guard let city = place?.locality, let street = place?.thoroughfare, let home = place?.subThoroughfare else {
//                                    debugPrint("cant get city and street from place")
//                                    return
//                                }
//                                self.orderInfo.fromPlace = city + ", " + street
//                                if home.characters.count > 0 {
//                                    self.orderInfo.fromPlace?.appendContentsOf(", \(home)")
//                                }
//
//                                }) { (error) -> Void in
//                                    debugPrint(error)
//                            }
//                        }
//                        }) { (error) -> Void in
//                            print(error)
//                    }
//                } catch {
//                    print(error)
//                }
        }
        
        let showOnMapRow = LabelRowFormer<CenterLabelCell>() {
            $0.textLabel?.text = "Указать на карте"
            }
            .onSelected { data in
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                    contr.initiator = NSStringFromClass(self.dynamicType)
                    contr.onSelected = {
                        self.orderInfo.toPlace = $0.address
                        self.orderInfo.coordinates = $0.coords
                    }
                    self.navigationController?.pushViewController(contr, animated: true)
                }
        }
        
        
        self.fromRow = fromRow
//////////////////////////////
        
        
////////// to place /////////////
        let toRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Куда?"
                $0.text = orderInfo.toPlace
                $0.rowHeight = 44
            }.onTextChanged {
                self.orderInfo.toPlace = $0
        }
        
        let findOnMapRow = LabelRowFormer<CenterLabelCell>() {
            $0.textLabel?.text = "Найти на карте"
            }
            .onSelected { _ in
                
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                if let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MapSTID.rawValue) as? MapViewController {
                    contr.initiator = NSStringFromClass(self.dynamicType)
                    contr.onSelected = {
                        self.orderInfo.toPlace = $0.address
                    }
                    self.navigationController?.pushViewController(contr, animated: true)
                }
        }
        
        self.toRow = toRow
//////////////////////////////
        
        
///////////price//////////////
        let priceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Цена"
            $0.textField.keyboardType = .DecimalPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Введите цену"
            }.onTextChanged {
                self.orderInfo.price = Int($0)
        }
//////////////////////////////
        
        
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
        
        
        let moreRow = SwitchRowFormer<FormSwitchCell>() {
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
        
        
        
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.text = text
                    $0.viewHeight = 44
            }
        }
        
        
        let segmentSection = SectionFormer(rowFormer: taxyTypeRow)
        let fromSection = SectionFormer(rowFormer: fromRow, getGeoRow, showOnMapRow)
            .set(headerViewFormer: createHeader("Откуда"))
        let toSection = SectionFormer(rowFormer: toRow, findOnMapRow)
            .set(headerViewFormer: createHeader("Куда"))
        let priceSection = SectionFormer(rowFormer: priceRow)
        let commentSection = SectionFormer(rowFormer: commentRow)
        let moreSection = SectionFormer(rowFormer: moreRow)

        
        former.append(sectionFormer: segmentSection, fromSection, toSection, priceSection, commentSection, moreSection)
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