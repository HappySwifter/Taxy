//
//  Helper.swift
//  Taxy
//
//  Created by Artem Valiev on 14.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import Foundation
import SwiftLocation
import SVProgressHUD


struct Helper {
        
    func showLoading(title: String? = "Загрузка") {
        SVProgressHUD.showWithStatus(title)
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
    func getAddres( completion: (String, CLLocationCoordinate2D) -> Void, failure: (String -> Void)) {
        getLocation { result in
            switch result {
            case .Response(let location):
                SwiftLocation.shared.reverseCoordinates(Service.GoogleMaps, coordinates: location.coordinate, onSuccess: { (place) -> Void in
                    guard var address = place?.locality else {
                        failure("Не удалось определить адрес")
                        return
                    }
                    if let street =  place?.thoroughfare where street.characters.count > 0 {
                        address.appendContentsOf(", \(street)")
                    }
                    
                    if let home =  place?.subThoroughfare where home.characters.count > 0 {
                        address.appendContentsOf(", \(home)")
                    }
                    completion(address, location.coordinate)
                    }) {
                        failure(String($0))
                }
            case .Error(let error):
                failure(error)
            }
            
        }
    }
    
    func getLocation( completion: Result<CLLocation, String> -> Void) {
        do {
            try SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 20, onSuccess: { (location) -> Void in
                if let location = location {
                    completion(Result.Response(location))
                } else {
                    completion(Result.Error("Не удалось определить координаты"))
                }
                
            }) { (error) -> Void in
                completion(Result.Error(error?.localizedDescription ?? "Ошибка определения геолокации"))
            }
        } catch {
            completion(Result.Error(String(error)))
        }
    }
    
    func canAcceptOrder(handler: Bool -> Void) {
        Networking.instanse.getOrders(0) { result in
            switch result {
            case .Error(let error):
                debugPrint(error)
            case .Response(let data):
                if data.count > 0 {
                    handler(false)
                } else {
                    handler(true)
                }
            }
            
        }
    }

    
}



extension UIImage {
    enum bla: String {
        case one = "one"
        case two = "two"
    }
    
    convenience init!(assetC: bla) {
        self.init(named: assetC.rawValue)
    }
    
    func toBase64() -> String? {
        if let imageData = UIImageJPEGRepresentation(self, 0.01) {
            return imageData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        } else {
            return nil
        }
    }
    
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}

extension String {
    func toImage() -> UIImage? {
        if let imageData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters),
        let image = UIImage(data: imageData) {
            return image
        }
        return .None
    }
    
    func dateFromString() -> NSDate? {
        let form = NSDateFormatter()
        let gmt = NSTimeZone(forSecondsFromGMT: 0)
        form.timeZone = gmt
        form.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return form.dateFromString(self)
    }
}

//extension NSError {
//    convenience init!(name: String) {
//        self.init(domain: name, code: 0, userInfo: nil)
//    }
//}

extension NSDate {
    
    func shortTime() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(self)
    }
    
    
}

extension UIFont {
    
//    convenience init!() {
//        self.init(name: "Helvetica Light", size: 13)!
//    }
    
    class func light_Small() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 13)!
    }
    class func light_Med() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 15)!
    }
    class func light_Lar() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 19)!
    }
    
    class func bold_Small() -> UIFont {
        return UIFont(name: "Helvetica Bold", size: 13)!
    }
    class func bold_Med() -> UIFont {
        return UIFont(name: "Helvetica Bold", size: 15)!
    }
    class func bold_Lar() -> UIFont {
        return UIFont(name: "Helvetica Bold", size: 19)!
    }

}

extension UIViewController {
    func instantiateSTID(id: STID) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let centerViewController = storyBoard.instantiateViewControllerWithIdentifier(id.rawValue)
        let nav = NavigationContr(rootViewController: centerViewController)
        self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
    }

//    func instantiateVC(contr: UIViewController) {
//        let nav = NavigationContr(rootViewController: contr)
//        self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
//    }
    
    func enableMenu() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyBoard.instantiateViewControllerWithIdentifier(STID.MenuSTID.rawValue)
        let navC = NavigationContr(rootViewController: vc)
        evo_drawerController?.leftDrawerViewController = navC
    }
    
    func disableMenu() {
        evo_drawerController?.leftDrawerViewController = .None
    }
}

