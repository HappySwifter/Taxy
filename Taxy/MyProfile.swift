// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import DrawerController
import UIKit
import Former



final class MyProfileVC: FormViewController, SegueHandlerType {
    
    internal var isRegistration = true
    
    enum SegueIdentifier: String {
        case DriverRegistrationSegue
    }
    
    // MARK: Public
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        setupMenuButtons()
        tableView.contentOffset = CGPointMake(0, 20)
    }
    
    
    // MARK: Private
    
    
    func loadProfile() {
        Helper().showLoading("Загрузка")
        Networking.instanse.getUserInfo { [weak self] result in
            Helper().hideLoading()
            self?.configure()
            self?.changeMoreInfoSection()
        }
    }
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    private lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell")) {
            $0.iconView.image = UserProfile.sharedInstance.image
            }
            .configure {
                $0.text = "Выберите фотографию"
                $0.rowHeight = 60
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                self?.presentImagePicker()
        }
    }()
    
    private lazy var moreSection: SectionFormer = {
      let moreRow = LabelRowFormer<CenterLabelCell> {
            $0.titleLabel.font = UIFont.light_Med()
            }
            .configure {
                $0.text = "Дополнительная информация"
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
                self?.performSegueWithIdentifier(.DriverRegistrationSegue, sender: self)
        }
        return SectionFormer(rowFormer: moreRow)
    }()

    
    private lazy var exitSection: SectionFormer = {
        let exitRow = LabelRowFormer<CenterLabelCell>() {
            $0.titleLabel.textColor = .redColor()
            }.configure {
                $0.text = "Выход"
            }.onSelected { [weak self] _ in
                LocalData().forgetUserProfile()
                LocalData().deleteUserID()
                self?.instantiateSTID(STID.LoginSTID)
        }
        
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        let exitSection = SectionFormer(rowFormer:exitRow)
            .set(headerViewFormer:
                LabelViewFormer<FormLabelHeaderView>().configure {
                    $0.viewHeight = 40
                    $0.text = "Выйти из учетной записи"
                })
        return exitSection
    }()


    private func configure() {
        
        
        title = "Мой профиль"
        tableView.contentInset.top = 40
        tableView.contentInset.bottom = 40
        
        // Create RowFomers
        let userTypeRow = SegmentedRowFormer<FormSegmentedCellNoTitle>{
            $0.tintColor = UIColor.mainOrangeColor()
            }
            .configure {
                $0.segmentTitles = ["Пассажир", "Водитель"]
                $0.selectedIndex = UserProfile.sharedInstance.type.rawValue - 1
            }.onSegmentSelected { [weak self]  index, _  in
                if index == 0 {
                    UserProfile.sharedInstance.type = .Passenger
                } else {
                    UserProfile.sharedInstance.type = .Driver
                }
                self?.changeMoreInfoSection()
        }
        
        
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Имя"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Ваше имя"
                if let name = UserProfile.sharedInstance.name {
                    $0.text = name
                }
            }.onTextChanged {
                UserProfile.sharedInstance.name = $0
        }
        
        let cityRow = InlinePickerRowFormer<ProfileLabelCell, String>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Город"
            }.configure {
                let savedCities = LocalData.instanse.cities
                $0.pickerItems = savedCities.map {
                    InlinePickerItem(title: $0.name)
                }
                if let city = UserProfile.sharedInstance.city {
                    $0.selectedRow = city.code ?? 0
                }
                //                else {
                //                    UserProfile.sharedInstance.city = 0
                //                }
            }
            .onValueChanged {
                let name = $0.title
                if let index = LocalData.instanse.cities.indexOf({$0.name == name}) {
                    UserProfile.sharedInstance.city = LocalData.instanse.cities[index]
                }
                
        }
        
        
        let phoneRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
            $0.titleLabel.text = "Телефон"
            $0.textField.enabled = false
            }.configure {
                $0.text = UserProfile.sharedInstance.phoneNumber
            }.onTextChanged {
                UserProfile.sharedInstance.phoneNumber = $0
        }
        
        let balanceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
            $0.titleLabel.text = "Баланс"
            $0.textField.enabled = false
            }.configure {
                if let balance = UserProfile.sharedInstance.balance {
                    $0.text = String(balance)
                }
        }

        
        let userIDRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
            $0.titleLabel.text = "user id"
            $0.textField.font = UIFont.systemFontOfSize(8)
            }.configure {
                if let id = UserProfile.sharedInstance.userID {
                    $0.text = id
                }
                $0.enabled = false
        }
        
  
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let userTypeSection = SectionFormer(rowFormer: userTypeRow)
            .set(headerViewFormer: createHeader(" "))
        let imageSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Фотография профиля"))
        let aboutSection = SectionFormer(rowFormer: nameRow, cityRow, phoneRow, balanceRow, userIDRow)
            .set(headerViewFormer: createHeader("Обо мне"))
        
        former.append(sectionFormer: userTypeSection, imageSection, aboutSection, moreSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        
        


        
        
        
        
        if !isRegistration {
            former.append(sectionFormer: exitSection)
        }
    }
    
    


    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func changeMoreInfoSection() {
        switch UserProfile.sharedInstance.type {
        case .Passenger:
            moreSection.rowFormers.first?.enabled = false
            moreSection.rowFormers.first?.update()
            
//            former.remove(sectionFormer: moreSection)
        case .Driver:
//            former.append(sectionFormer: moreSection)
//            former.insert(sectionFormer: moreSection, toSection: former.numberOfSections)
            moreSection.rowFormers.first?.enabled = true
            moreSection.rowFormers.first?.update()
            
        }
    }
    
    
    func setupMenuButtons() {
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: "doneTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
        
        if !isRegistration {
            let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
            self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
        }
        
    }
    
    
    func doneTouched() -> Void {
        view.endEditing(true)
        guard UserProfile.sharedInstance.city?.code != 0  else {
            Popup.instanse.showInfo("Внимание", message: "Выберите Ваш город")
            return
        }
        guard UserProfile.sharedInstance.city != nil  else {
            Popup.instanse.showInfo("Внимание", message: "Выберите Ваш город")
            return
        }
        
        if isRegistration == true {
            
            switch UserProfile.sharedInstance.type {
            case .Passenger:
                Helper().showLoading("Обновление профиля")
                Networking().updateProfile(UserProfile.sharedInstance) { [weak self]  result in
                    Helper().hideLoading()
                    
                    switch result {
                    case .Error(let error):
                        Popup.instanse.showError("", message: error)
                        
                    case .Response(_):
                        self?.enableMenu()
                        self?.instantiateSTID(STID.MakeOrderSTID)
                    }
                }
                
            case .Driver:
                performSegueWithIdentifier(.DriverRegistrationSegue, sender: self)
            }
            
        } else {
            Helper().showLoading("Обновление профиля")
            Networking().updateProfile(UserProfile.sharedInstance) { [weak self]  result in
                Helper().hideLoading()
                switch result {
                case .Error(let error):
                    Popup.instanse.showError("", message: error)
                case .Response(_):
                   debugPrint("profile updated")
                }
            }
        }
    }
    
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segueIdentifierForSegue(segue) {
//        case .DriverRegistrationSegue:
//            if let contr = segue.destinationViewController as? DriverRegistrationVC {
////                contr.userInfo = UserProfile.sharedInstance
//            }
//        }
//    }
    
}



extension MyProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let resizedImage = image.resizeToWidth(300)
        UserProfile.sharedInstance.image = resizedImage
        imageRow.cellUpdate {
            $0.iconView.image = resizedImage
        }
    }
}
