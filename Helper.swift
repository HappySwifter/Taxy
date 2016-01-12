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


extension String{
    func toImage() -> UIImage? {
        guard let decodedData = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0) ) else { return nil }
        guard let decodedImage = UIImage(data: decodedData) else { return nil }
        return decodedImage
    }
}