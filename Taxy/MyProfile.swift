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
    //    var userInfo: UserProfile = UserProfile()
    
    enum SegueIdentifier: String {
        case DriverRegistrationSegue
    }
    
    // MARK: Public
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        setupMenuButtons()
        configure()
    }
    
    
    // MARK: Private
    
    
    func loadProfile() {
        Helper().showLoading("Загрузка")
        Networking.instanse.getUserInfo { result in
            Helper().hideLoading()
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
            }.onSegmentSelected {  index, _  in
                if index == 0 {
                    UserProfile.sharedInstance.type = .Passenger
                } else {
                    UserProfile.sharedInstance.type = .Driver
                }
        }
        
        
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Имя"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            $0.textField.font = UIFont.systemFontOfSize(8)
            }.configure {
                $0.placeholder = "Ваше имя"
                if let name = UserProfile.sharedInstance.name, id = UserProfile.sharedInstance.userID
                {
                    $0.text = name + " " + id
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
            }.configure {
                $0.text = UserProfile.sharedInstance.phoneNumber
                $0.enabled = false
        }
        
        
        
        
        
        // Create Headers
        
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let userTypeSection = SectionFormer(rowFormer: userTypeRow)
            .set(headerViewFormer: createHeader("Кто вы?"))
        let imageSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Фотография профиля"))
        let aboutSection = SectionFormer(rowFormer: nameRow, cityRow, phoneRow)
            .set(headerViewFormer: createHeader("Обо мне"))
        
        former.append(sectionFormer: userTypeSection, imageSection, aboutSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        
        if !isRegistration {
            let exitRow = LabelRowFormer<CenterLabelCell>() {
                $0.titleLabel.textColor = .redColor()
                }.configure {
                    $0.text = "Выход"
                }.onSelected { [weak self] _ in
                    LocalData().forgetUserProfile()
                    LocalData().deleteUserID()
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.LoginSTID.rawValue)
                    let nav = NavigationContr(rootViewController: contr)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
            }
            let exitSection = SectionFormer(rowFormer:exitRow)
                .set(headerViewFormer: createHeader("Выйти из учетной записи"))
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
    
    
    func setupMenuButtons() {
        
        
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .Plain, target: self, action: "doneTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
        
        if !isRegistration {
            let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
            self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
        }
        
    }
    
    
    func doneTouched() -> Void {
        
        guard UserProfile.sharedInstance.city?.code != 0  else {
            Popup.instanse.showInfo("Внимание", message: "Выберите Ваш город")
            return
        }
        
        
        guard UserProfile.sharedInstance.city != nil  else {
            Popup.instanse.showInfo("Внимание", message: "Выберите Ваш город")
            return
        }
        
        
        if isRegistration == true {
            
            
            
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            switch UserProfile.sharedInstance.type {
            case .Passenger:
                
                Networking().updateProfile(UserProfile.sharedInstance) { [weak self]  data in
                    //                        LocalData().savePhone(data)
                    
                    
                    let vc = MenuVC()
                    let navC = UINavigationController(rootViewController: vc)
                    self?.evo_drawerController?.leftDrawerViewController = navC
                    
                    let contr = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue)
                    let nav = NavigationContr(rootViewController: contr)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                }
                
                
            case .Driver:
                performSegueWithIdentifier(.DriverRegistrationSegue, sender: self)
                //                    performSegueWithIdentifier("DriverRegistrationSegue", sender: nil)
            }
            
        } else {
            Networking().updateProfile(UserProfile.sharedInstance) { [weak self]  data in
                
            }
        }
    }
    
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "DriverRegistrationSegue" {
    //            if let contr = segue.destinationViewController as? DriverRegistrationVC {
    //                contr.userInfo = userInfo
    //            }
    //        }
    //    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .DriverRegistrationSegue:
            if let contr = segue.destinationViewController as? DriverRegistrationVC {
                contr.userInfo = UserProfile.sharedInstance
            }
        }
    }
    
}



extension MyProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        UserProfile.sharedInstance.image = image
        imageRow.cellUpdate {
            $0.iconView.image = image
        }
    }
}
