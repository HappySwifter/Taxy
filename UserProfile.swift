//
//  Profile.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum userType: Int {
    case Passenger = 1
    case Driver
}

enum DriverState: Int {
    case Free
    case Busy
//    static func value() -> [DriverState] {
//        return [Free, Busy]
//    }
}


class UserProfile {
    
    static let sharedInstance = UserProfile()
    
    var image: UIImage?
    var name: String?
    var gender: String?
    var birthDay: NSDate?
    var city: City?
    var phoneNumber: String?
    var type: userType = .Passenger
    var balance: Int?
    // Driver
    var pravaPhoto: UIImage?
    var carPhoto: UIImage?
    var userID: String?
    var withChildChair = false
    var location: Location?
    var driverState: DriverState = .Free

    func getModelFromDict(userInfo: [String: JSON], shared: Bool) -> UserProfile {
        let profile = shared ? UserProfile.sharedInstance : UserProfile()
        
        if let imageString = userInfo[UserFields.Image.rawValue]?.string {
            profile.image = imageString.toImage()
        }
        if let carImageString = userInfo[UserFields.CarPhoto.rawValue]?.string {
            profile.carPhoto = carImageString.toImage()
        }
        if let cities = LocalData.instanse.getCities() {
            let cityID = userInfo[UserFields.City.rawValue]?.int
            let city = cities.filter{ $0.code == cityID }.first
            profile.city = city
        }
        if let type = userInfo[UserFields.UserType.rawValue]?.int {
            if let type1 = userType(rawValue: type) {
                profile.type = type1
            }
        }
        if let driverState = userInfo[UserFields.DriverState.rawValue]?.int  {
            if let state = DriverState(rawValue: driverState - 1) {
                profile.driverState = state
            } else {
                debugPrint("cant determine driver state in \(__FUNCTION__) : \(__FILE__)")
            }
        }
        
        
        
        profile.name = userInfo[UserFields.FirstName.rawValue]?.string
        profile.userID = userInfo[UserFields.Id.rawValue]?.string
        profile.phoneNumber = userInfo[UserFields.PhoneNumber.rawValue]?.string
        profile.balance = userInfo[UserFields.Balance.rawValue]?.int
        profile.withChildChair = userInfo[UserFields.WithChildChair.rawValue]?.bool ?? false
        
        
        
        if let lat = userInfo[UserFields.Latitude.rawValue]?.double,
        let lon = userInfo[UserFields.Longitude.rawValue]?.double,
        let timeStr = userInfo[UserFields.LocationUpdatedAt.rawValue]?.string,
        let time = timeStr.dateFromString()
        {
            profile.location = Location(coordinates:CLLocationCoordinate2DMake(lat, lon), updatedAt: time)
//            profile.location = CLLocationCoordinate2DMake(lat, lon)
        } else { debugPrint("cant parse location/time") }
        return profile
    }
    
}

enum UserFields: String {
    case Id, FirstName, City, UserType, Image, PhoneNumber, Balance, CarPhoto, WithChildChair, Longitude, Latitude, LocationUpdatedAt, DriverState
}
