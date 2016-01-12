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
    var userInfo: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButtons()
        configure()
        
    }
    


    
    func setupMenuButtons() {

        let doneButton = UIBarButtonItem(title: "Отправить", style: .Plain, target: self, action: "doneTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
    }
    
    func doneTouched() {
        if let userInfo = userInfo {
            Networking().updateProfile(userInfo) { [weak self]  data in
//                LocalData().savePhone(data)
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue)
                let nav = NavigationContr(rootViewController: contr)
                self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            }
        }
    }
    
    

    private lazy var pravaRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell"))
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
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell"))
            .configure {
                $0.text = "Фото машины"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.selectedRow = 1
                self?.former.deselect(true)
                self?.presentImagePicker()
        }
    }()

    
    private func configure() {
        
        let descriptionHeader = LabelViewFormer<FormLabelHeaderView>() {
            $0.contentView.backgroundColor = .clearColor()
            $0.titleLabel.textColor = .grayColor()
            $0.titleLabel.font = .systemFontOfSize(17)
            }.configure {
                $0.viewHeight = 150
                $0.text = "Почти готово! Загрузите фотографию своей машины и водительского удостоверения. После того, как наши диспетчеры их проверят, вам придет СМС о подтверждении регистрации"
//                $0.textAligment = .Center
        }

        let section = SectionFormer(rowFormers: [pravaRow, carRow])
        .set(headerViewFormer: descriptionHeader)
        former.add(sectionFormers: [section])
        
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

        switch selectedRow {
        case 0:
            pravaRow.cellUpdate {
                userInfo?.pravaPhoto = image
                $0.iconView.image = image
            }
            
        case 1:
            carRow.cellUpdate {
                userInfo?.carPhoto = image
                $0.iconView.image = image
            }
            
        default:
            break
        }
    }
}

