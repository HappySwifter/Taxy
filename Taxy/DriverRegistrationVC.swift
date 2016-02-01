//
//  DriverRegistrationVC.swift
//  Taxy
//
//  Created by Artem Valiev on 09.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import Former

final class DriverRegistrationVC: FormViewController {
    
    private var selectedRow = 0
//    var userInfo: UserProfile?
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButtons()
        configure()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Networking().updateProfile(UserProfile.sharedInstance) { _ in }
    }

    
    func setupMenuButtons() {

        let doneButton = UIBarButtonItem(title: "Отправить", style: .Plain, target: self, action: "doneTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
    }
    
    func doneTouched() {
        Helper().showLoading("Обновление профиля")
        Networking().updateProfile(UserProfile.sharedInstance) { [weak self]  data in
            Helper().hideLoading()
            self?.enableMenu()
            self?.instantiateSTID(STID.FindOrdersSTID)
        }
    }
    
    

    private lazy var pravaRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            $0.iconView.image = UserProfile.sharedInstance.pravaPhoto
            }
            .configure {
                $0.text = "Фото прав"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.selectedRow = 0
                self?.former.deselect(true)
                self?.presentImagePicker()
        }
    }()

    
    private lazy var carRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            $0.iconView.image = UserProfile.sharedInstance.carPhoto
            }
            .configure {
                $0.text = "Фото машины"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.selectedRow = 1
                self?.former.deselect(true)
                self?.presentImagePicker()
        }
    }()
    
    
    private lazy var carModelRow: TextFieldRowFormer<FormTextFieldCell> = { [weak self] _ in
        TextFieldRowFormer<FormTextFieldCell> {
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.titleLabel.text = "Марка"
            $0.titleLabel.font = .bold_Med()
            $0.textField.textColor = .formerSubColor()
            $0.textField.placeholder = "Марка вашей машины"
            }.configure {
                $0.text = UserProfile.sharedInstance.carModel
            }
            .onTextChanged {
                UserProfile.sharedInstance.carModel = $0
        }
    }()
    
    private lazy var carNumberRow: TextFieldRowFormer<FormTextFieldCell> = { [weak self] _ in
        TextFieldRowFormer<FormTextFieldCell> {
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.titleLabel.text = "Номер"
            $0.textField.placeholder = "Номер вашей машины"
            $0.titleLabel.font = .bold_Med()
            $0.textField.textColor = .formerSubColor()
            }.configure {
                $0.text = UserProfile.sharedInstance.carNumber
            }
            .onTextChanged {
                UserProfile.sharedInstance.carNumber = $0
        }
    }()

    private lazy var carColorRow: TextFieldRowFormer<FormTextFieldCell> = { [weak self] _ in
        TextFieldRowFormer<FormTextFieldCell> {
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.titleLabel.text = "Цвет"
            $0.textField.placeholder = "Цвет вашей машины"
            $0.titleLabel.font = .bold_Med()
            $0.textField.textColor = .formerSubColor()
            }.configure {
                $0.text = UserProfile.sharedInstance.carColor
            }
            .onTextChanged {
                UserProfile.sharedInstance.carColor = $0
        }
    }()
    
    
    private func configure() {
        
        
        
        
        
        let descriptionHeader = LabelViewFormer<FormLabelHeaderView>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .grayColor()
            $0.titleLabel.font = .bold_Med()
            }.configure {
                $0.viewHeight = 150
                $0.text = "Почти готово! Загрузите фотографию своей машины и водительского удостоверения. После того, как наши диспетчеры их проверят, вам придет СМС о подтверждении регистрации"
//                $0.textAligment = .Center
        }
        
        let descriptionHeader2 = LabelViewFormer<FormLabelHeaderView>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .grayColor()
            $0.titleLabel.font = .bold_Med()
            }.configure {
                $0.viewHeight = 40
                $0.text = "Информация о машине"
        }
        
        
        let childChairRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "Детское кресло"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = UIFont.bold_Med()
            $0.switchButton.onTintColor = .formerSubColor()
            }.configure {
                $0.switchWhenSelected = true
                $0.switched = UserProfile.sharedInstance.withChildChair
            }.onSwitchChanged {
                UserProfile.sharedInstance.withChildChair = $0
        }
        
        let rows = [pravaRow, carRow, ]

        
        let section = SectionFormer(rowFormers: rows)
        .set(headerViewFormer: descriptionHeader)
        
        let section2 = SectionFormer(rowFormer: childChairRow, carModelRow, carNumberRow, carColorRow)
         .set(headerViewFormer: descriptionHeader2)
        
        former.add(sectionFormers: [section, section2])
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
    }

    
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
}


extension DriverRegistrationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        let resizedImage = image.resizeToWidth(300)
        switch selectedRow {
        case 0:
            pravaRow.cellUpdate {
                UserProfile.sharedInstance.pravaPhoto = resizedImage
                $0.iconView.image = resizedImage
            }
            
        case 1:
            carRow.cellUpdate {
                UserProfile.sharedInstance.carPhoto = resizedImage
                $0.iconView.image = resizedImage
            }
            
        default:
            break
        }
    }
}

