//
//  Networking.swift
//  Taxy
//
//  Created by Artem Valiev on 03.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import netfox


enum LoadingError: String {
    case noID
    case ServerError = "Ошибка сервера"
    case OrderNotCreated = "Заказ не создан"
    case UnexpectedError = "Неожиданная ошибка"
    case GetCityError = "Не удалось загрузить список городов"

}



class NFXManager: Alamofire.Manager
{
    static let sharedManager: NFXManager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.protocolClasses?.insert(NFXProtocol.self, atIndex: 0)
        let manager = NFXManager(configuration: configuration)
        return manager
    }()
}

final class Networking {
    static let instanse = Networking()
    let orderString = "order/"
    let userString = "user/"
    let serviceString = "service/"
    
    
    func getSms (loginInfo: Login?, completion: Result<String, String> -> Void)  {
        guard let phone = loginInfo?.phone else {
//            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [
            "phone": phone
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.GetCode.rawValue, params: parameters) { result in
            
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let data = json.string {
                    completion(Result.Response(data))
                }
            }
        }
    }
    
    
    func checkPincode (loginInfo: Login?, completion: Result<String, String>  -> Void) {
        
        guard let id = loginInfo?.id, pincode = loginInfo?.pincode else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [
            "id": id,
            "code" : pincode
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.VerifyCode.rawValue, params: parameters) { result in
            
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let data = json.string {
                    completion(Result.Response(data))
                }
            }
        }
    }
    
    
    func updateProfile (userProfile: UserProfile, completion: Result<String, String>  -> Void) {
        
        var parameters = [String: AnyObject]()
        
        guard let id = LocalData().getUserID else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        parameters[UserFields.id.rawValue] = id
        
        if let city = userProfile.city {
            parameters[UserFields.City.rawValue] = String(city.code)
        }
        if let name = userProfile.name {
            parameters[UserFields.FirstName.rawValue] = name
        }
        
        parameters[UserFields.UserType.rawValue] = userProfile.type.rawValue

        
//        switch userProfile.type {
//        case .Driver:
//            parameters["UserType"] = "Driver"
//        case .Passenger:
//            parameters["UserType"] = "Passenger"
//        }
        if let image = userProfile.image {
            if let base64 = image.toBase64() {
                parameters[UserFields.Image.rawValue] = base64
            }
        }
        🙏(.POST, url: mainUrl + userString + ServerMethods.UpdateProfile.rawValue, params: parameters) { result in
            
            
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let userInfo = json.dictionary {
                    UserProfile.sharedInstance.updateInstanseWithJSON(userInfo)
                    completion(Result.Response(""))
                }
            }
        }
    }
    
    
    func getUserInfo (completion: Result<String, String>  -> Void) {
        
        guard let userId = LocalData().getUserID else {
            Popup.instanse.showError("", message: "Не обнружен id пользователя")
            completion(Result.Error("Не обнружен id пользователя"))
            return
        }
        
        let parameters = [
            "id": userId
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.GetUserInfo.rawValue, params: parameters) { result in
            
            
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let userInfo = json.dictionary {
                    UserProfile.sharedInstance.updateInstanseWithJSON(userInfo)
                    completion(Result.Response(""))
                }
            }
        }
    }
    
    
    func getCities(completion: Result<[City], String> -> Void) {
        🙏(.POST, url: mainUrl + serviceString + ServerMethods.GetCities.rawValue, params: nil) { result in
            
            
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                var cities: [City] = []
                
                for (_,subJson):(String, JSON) in json {
                    guard var city = subJson["Name"].string, let code = subJson["Code"].int else {
                        completion(Result.Error(LoadingError.GetCityError.rawValue))
                        return
                    }
                    debugPrint(city)
                    if city == "None" {
                        city = "Выберите город"
                    }
                    let newCity = City(name: city, code: code)
                    cities.append(newCity)
                }
                completion(Result.Response(cities))
            }
        }
    }
    
// MARK: ORDERS
    func createOrder (order: Order, _ completion: Result<String, String> -> Void) {
        
        var parameters = [String: String]()
        
        guard let id = LocalData().getUserID, let fromPlace = order.fromPlace  else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        parameters[OrderFields.UserId.rawValue] = id
        parameters[OrderFields.FromAddress.rawValue] = fromPlace
        parameters[OrderFields.OrderType.rawValue] = order.orderType.rawValue
//        parameters["isCab"] = String(order.isCab)
        parameters[OrderFields.WithChildChair.rawValue] = String(order.isChildChair)

        if let toPlace = order.toPlace {
            parameters[OrderFields.ToAddress.rawValue] = toPlace
        }
        if let price = order.price {
            parameters[OrderFields.Price.rawValue] = String(price)
        }
        if let comment = order.comment {
            parameters[OrderFields.Comment.rawValue] = comment
        }
        
        🙏(.POST, url: mainUrl + orderString + ServerMethods.CreateOrder.rawValue, params: parameters) { result in
            
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let orderID = Order().getOrderIDFromResponse(json) {
                    completion(Result.Response(orderID))
                } else {
                    completion(Result.Error(LoadingError.OrderNotCreated.rawValue))
                }
            }
        }
    }
    
    
    func cancelOrder(order: Order, _ completion: Result<String, String> -> Void) {
        guard let id = LocalData().getUserID, orderID = order.orderID else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [
            "UserId" : id,
            "Id" : orderID
        ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.CancelOrder.rawValue, params: parameters) { result in

            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(_):
                completion(Result.Response(""))
            }
        }
    }
    
    func getOrders(orderType: Int, completion: Result<[Order], String> -> Void) {
        
        guard let id = LocalData().getUserID  else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        
        let parameters = [
            "id" : id,
            "OrderType" : String(orderType)
        ]
        
        🙏(.POST, url: mainUrl + orderString + ServerMethods.GetOrders.rawValue, params: parameters) { result in
            
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                print(json)
                let parsedOrders = Order().getOrdersFomResponse(json)
                completion(Result.Response(parsedOrders))
                
            }
        }
        
    }
    
    func monitorOrderStatus(order: Order, completion: Result<Int, String> -> Void) {
        guard let id = LocalData().getUserID, orderID = order.orderID  else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [
            "userId" : id,
            "orderId" : orderID
        ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.CheckOrder.rawValue, params: parameters) { result in
            
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
 
            case .Response(let json):
                if let orderStatus = Order().getOrderStatusFromResponse(json) {
                    completion(Result.Response(orderStatus))
                } else {
                    completion(Result.Error(LoadingError.UnexpectedError.rawValue))
                }
            }
        }
    }
    
    
    
    func closeOrder(order: Order, completion: Result<String, String> -> Void) {
        guard let orderID = order.orderID else {
            Popup.instanse.showError("cant close order. No orderID passed", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [ OrderFields.Id.rawValue : orderID ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.СloseOrder.rawValue, params: parameters) { result in
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(_):
                completion(Result.Response(""))
            }
        }
    }
    
    func getOnlyMyOrder(order: UserProfile, completion: Result<Int, String> -> Void) {
        guard let id = LocalData().getUserID else {
            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [ UserFields.id.rawValue : id ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.GetOnlyMyOrder.rawValue, params: parameters) { result in
            
        }
    }
    
    
    
    func sendCoordinates(coordinates: CLLocationCoordinate2D) {
        guard let id = LocalData().getUserID else {
//            Popup.instanse.showError("", message: "\(__FUNCTION__)")
            return
        }
        let parameters = [
            "UserId" : id,
            "Latitude" : String(coordinates.latitude),
            "Longitude": String(coordinates.longitude)
        ]
        let url = mainUrl + orderString + ServerMethods.SendCoordinates.rawValue
        🙏(.POST, url: url, params: parameters) { result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            default:
                break
            }
        }
    }
    
    
    private func 🙏(method: Alamofire.Method, url: String, params: [String: AnyObject]?, completion: Result<JSON, String>  -> Void) {
        
        NFXManager.sharedManager.request(method, url, parameters: params)
            .validate()
            .responseJSON { response in
                debugPrint("🙏 \(response.result), \(response.request!.URL!), \((params))")
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let errorCode = json[Status].int {
                            if errorCode == 200 {
                                completion(Result.Response(json[Data]))
                            } else {
                              let errorDesc = errorDecription().getErrorName(errorCode)
                                completion(Result.Error(errorDesc))
                            }
                        }
                    }
                case .Failure(let error):
                    completion(Result.Error(error.localizedDescription))
                }
        }
    }
}
