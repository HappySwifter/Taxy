//
//  Bot.swift
//  Taxy
//
//  Created by Artem Valiev on 20.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation


class Bot {
    
    func createUser(info: UserProfile, handler: String -> Void) {
        
//        let loginInfo = Login()
////        let userProfile = UserProfile()
//        
//        loginInfo.phone = String(generateRandomNumber(8))
//        Networking.instanse.getSms(loginInfo) { result in
//            
//            switch result {
//            case .Error(let error):
//                Popup.instanse.showError("", message: error)
//            case .Response(let data):
//                loginInfo.pincode = "11111"
//                loginInfo.id = data
//                Networking.instanse.checkPincode(loginInfo) { result in
//                    
//                    LocalData.instanse.saveUserID(loginInfo.id!)
//                    Networking.instanse.updateProfile(info) { status in
//                        switch result {
//                        case .Response(_):
//                            handler(loginInfo.id!)
//                        default:
//                            break
//                        }
//                        
//                    }
//                }
//            }
        
            
//        }
    }
    
    
    
    
    
    func generateRandomNumber(numDigits: Int) -> Int{
        var place = 1
        var finalNumber: Int = 0;
        for(var i = 0; i < numDigits; i++){
            place *= 10
            let randomNumber = Int(arc4random_uniform(10))
            finalNumber = finalNumber + (randomNumber * place)
        }
        finalNumber = finalNumber + 1000000000
        return finalNumber
    }
}




