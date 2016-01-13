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
    
/////////// DATE ////////////
    func dateFromString(dateStr: String) -> NSDate? {
        let form = NSDateFormatter()
        let gmt = NSTimeZone(forSecondsFromGMT: 0)
        form.timeZone = gmt
        form.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return form.dateFromString(dateStr)
    }   
////////////////////////////
    
    func showLoading(title: String? = "Загрузка") {
        SVProgressHUD.showWithStatus(title)
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
    func getAddres( completion: (String, CLLocationCoordinate2D) ->Void ) {
        getLocation { location in
            SwiftLocation.shared.reverseCoordinates(Service.GoogleMaps, coordinates: location.coordinate, onSuccess: { (place) -> Void in
                guard let city = place?.locality, let street = place?.thoroughfare, let home = place?.subThoroughfare else {
                    debugPrint("cant get city and street from place")
                    return
                }
                var address = city + ", " + street
                if home.characters.count > 0 {
                    address.appendContentsOf(", \(home)")
                    completion(address, location.coordinate)
                }
                }) { (error) -> Void in
                    debugPrint(error)
            }
        }
    }
    
    func getLocation( completion: CLLocation -> Void) {
        do {
            try SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 20, onSuccess: { (location) -> Void in
                if let location = location {
                    completion(location)
                } else {
                    print("cant find coords")
                }
                
            }) { (error) -> Void in
                print(error)
            }
        } catch {
            print(error)
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


extension String{

}