//
//  LocalData.swift
//  Taxy
//
//  Created by iosdev on 10.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

class LocalData {
    
    static let instanse = LocalData()
    var cities: [City] = []
    
    let userID = "userID"
    func saveUserID(id: String) {
        debugPrint("saving userID \(id)")
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(id, forKey: userID)
        def.synchronize()
    }
    var getUserID: String? = {
        let def = NSUserDefaults.standardUserDefaults()
        let userId = def.objectForKey("userID") as? String
        debugPrint("getting userID \(userId)")

        return userId
    }()
    
    func deleteUserID() {
        debugPrint("deleting userID")
        let def = NSUserDefaults.standardUserDefaults()
        def.removeObjectForKey(userID)
    }
    
    
    func saveCities(cities: [City]) {
        self.cities = cities
    }
    func getCities() -> [City]?  {
        return cities
    }
    
    func forgetUserProfile() {
        UserProfile.sharedInstance.userID = nil
        UserProfile.sharedInstance.birthDay = nil
        UserProfile.sharedInstance.carPhoto = nil
        UserProfile.sharedInstance.city = nil
        UserProfile.sharedInstance.gender = nil
        UserProfile.sharedInstance.image = nil
        UserProfile.sharedInstance.name = nil
        UserProfile.sharedInstance.phoneNumber = nil
        UserProfile.sharedInstance.pravaPhoto = nil
        UserProfile.sharedInstance.type = .Passenger
        UserProfile.sharedInstance.location = nil
        UserProfile.sharedInstance.driverState = .Free
        UserProfile.sharedInstance.withChildChair = false
    }
    
}