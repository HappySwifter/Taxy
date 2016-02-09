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
    
    
    func getSms (phone: String, completion: Result<String, String> -> Void)  {
//        guard let phone = loginInfo?.phone else {
//            debugPrint("\(__FUNCTION__)")
//            completion(Result.Error("Ошибка"))
//            return
//        }
        let parameters = [
            "phone": phone
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.GetCode.rawValue, params: parameters) { result in
            
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(_):
                completion(Result.Response(""))
            }
        }
    }
    
    
    func checkPincode (phone: String, pinCode: String, completion: Result<String, String>  -> Void) {
        
//        guard let pincode = loginInfo?.pincode else {
//            debugPrint("\(__FUNCTION__)")
//            completion(Result.Error("Ошибка"))
//            return
//        }
        let parameters = [
            "phone": phone,
            "code" : pinCode
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
    
    
    
    func updateBalance(completion: Result<String, String>  -> Void) {
        guard let id = LocalData().getUserID else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        let parameters = [
            "id": id,
            "sum": String(100)
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.UpdateBalance.rawValue, params: parameters) { result in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
            case .Response(_):
                completion(Result.Response(""))
            }
        }
        
    }
    
    func updateProfile (userProfile: UserProfile, completion: Result<String, String>  -> Void) {
        
        var parameters = [String: AnyObject]()
        
        guard let id = LocalData().getUserID else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        parameters[UserFields.Id.rawValue] = id
        
        if let city = userProfile.city {
            parameters[UserFields.City.rawValue] = String(city.code)
        }
        if let name = userProfile.name {
            parameters[UserFields.FirstName.rawValue] = name
        }
        
        if let model = userProfile.carModel {
            parameters[UserFields.CarModel.rawValue] = model
        }
        if let number = userProfile.carNumber {
            parameters[UserFields.CarNumber.rawValue] = number
        }
        if let color = userProfile.carColor {
            parameters[UserFields.CarColor.rawValue] = color
        }
        
        parameters[UserFields.UserType.rawValue] = userProfile.type.rawValue
        parameters[UserFields.DriverState.rawValue] = userProfile.driverState.rawValue + 1
        parameters[UserFields.WithChildChair.rawValue] = String(userProfile.withChildChair)


        if let image = userProfile.image, base64 = image.toBase64() {
            parameters[UserFields.Image.rawValue] = base64
        }
        if let carPhoto = userProfile.carPhoto, let base64 = carPhoto.toBase64() {
            parameters[UserFields.CarPhoto.rawValue] = base64
        }
        if let pravaPhoto = userProfile.pravaPhoto, let base64 = pravaPhoto.toBase64() {
            parameters[UserFields.DriverLicense.rawValue] = base64
        }
        
        🙏(.POST, url: mainUrl + userString + ServerMethods.UpdateProfile.rawValue, params: parameters) { result in
            
            
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let userInfo = json.dictionary {
                    UserProfile.sharedInstance.getModelFromDict(userInfo, shared: true)
                    completion(Result.Response(""))
                }
            }
        }
    }
    
    func changeUserState (state: Int, completion: Result<Int, String>  -> Void) {
        guard let userId = LocalData().getUserID else {
            debugPrint("Не обнружен id пользователя \(__FUNCTION__)")
            completion(Result.Error("Не обнружен id пользователя"))
            return
        }
        let parameters = [
            "id": userId,
            "State": String(state + 1)
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.SetDriverState.rawValue, params: parameters) { result in
            switch result {
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                if let state = json.int {
                    completion(Result.Response(state - 1))
                } else {
                    completion(Result.Error("Ошибка сервера"))
                }
            }
        }
    }
    
    
    func getUserInfo (completion: Result<String, String>  -> Void) {
        
        guard let userId = LocalData().getUserID else {
            debugPrint("Не обнружен id пользователя \(__FUNCTION__)")
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
                    UserProfile.sharedInstance.getModelFromDict(userInfo, shared: true)
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
    
    func rateDriver(driverId: String, value: Int) {
        
        guard let userId = LocalData().getUserID else {
            debugPrint("\(__FUNCTION__)")
            return
        }
        let params = [
            "id": userId,
            "driverId": driverId,
            "rate": String(value)
        ]
        🙏(.POST, url: mainUrl + userString + ServerMethods.Rate.rawValue, params: params) { result in
            switch result {
            case .Error(let error):
                debugPrint(error)
            default:
                break
            }
        }
    }
    
    
    
// MARK: ORDERS
    func createOrder (order: Order, _ completion: Result<String, String> -> Void) {
        
        var parameters = [String: String]()
        
        guard let id = LocalData().getUserID, let fromPlace = order.fromPlace  else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        if let lon = order.fromPlaceCoordinates?.longitude, let lat = order.fromPlaceCoordinates?.latitude {
            parameters[OrderFields.FromLongitude.rawValue] = String(lon)
            parameters[OrderFields.FromLatitude.rawValue] = String(lat)
        }
        parameters[OrderFields.UserId.rawValue] = id
        parameters[OrderFields.FromAddress.rawValue] = fromPlace
        parameters[OrderFields.OrderType.rawValue] = String(order.orderType.hashValue + 1)
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
        if let city = UserProfile.sharedInstance.city {
            parameters[OrderFields.City.rawValue] = String(city.code)
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
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Не найден заказ"))
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
    
    func getOrders(orderType: Int, find: Bool = false, completion: Result<[Order], String> -> Void) {
        
        guard let id = LocalData().getUserID  else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        
        let parameters = [
            "id" : id,
            "OrderType" : String(orderType)
        ]
        
        let method = find ? ServerMethods.FindOrders.rawValue : ServerMethods.GetOrders.rawValue
        🙏(.POST, url: mainUrl + orderString + method, params: parameters) { result in
            
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

    
    func rejectOrder(orderId: String) {
        guard let id = LocalData().getUserID  else {
            debugPrint("\(__FUNCTION__)")
            return
        }
        let parameters = [
            "UserId" : id,
            "Id" : orderId
        ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.RejectOrder.rawValue, params: parameters) { result in
            
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: "\(error) \(__FUNCTION__)")
                
            case .Response(_):
                print("REJECTED")
            }
        }
    }
    
    
    
    func checkOrder(order: Order, completion: Result<[Order], String> -> Void) {
        guard let id = LocalData().getUserID, orderID = order.orderID  else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
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
                let orders = Order().getOrdersFomResponse(json)
                completion(Result.Response(orders))
            }
        }
    }
    
    
    
    func closeOrder(order: Order, completion: Result<String, String> -> Void) {
        guard let id = LocalData().getUserID, let orderID = order.orderID else {
            Popup.instanse.showError("cant close order. No orderID passed", message: "\(__FUNCTION__)")
            debugPrint("cant close order. No orderID passed in\(__FUNCTION__)")
            completion(Result.Error("Не получается закрыть заказ"))
            return
        }
        let parameters = [
            OrderFields.Id.rawValue : orderID,
            OrderFields.UserId.rawValue : id]
        // СloseOrder
        🙏(.POST, url: mainUrl + orderString + ServerMethods.CloseOrder.rawValue, params: parameters) { result in
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(_):
                completion(Result.Response(""))
            }
        }
    }
    
    func getOnlyMyOrder(completion: Result<[Order], String> -> ()) {
        guard let id = LocalData().getUserID else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        let parameters = [ "userId" : id ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.GetOnlyMyOrder.rawValue, params: parameters) { result in
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                 let orders = Order().getOrdersFomResponse(json)
                 completion(Result.Response(orders))
            }
        }
    }
    
    func acceptOrder(orderId: String, completion: Result<[Order], String> -> Void) {
        guard let id = LocalData().getUserID else {
            debugPrint("\(__FUNCTION__)")
            completion(Result.Error("Ошибка"))
            return
        }
        let parameters = [
            "driverId" : id,
            "orderId" : orderId
        ]
        🙏(.POST, url: mainUrl + orderString + ServerMethods.AcceptOrder.rawValue, params: parameters) { result in
            switch result {
                
            case .Error(let error):
                completion(Result.Error(error))
                
            case .Response(let json):
                let orders = Order().getOrdersFomResponse(json)
                completion(Result.Response(orders))
            }
        }
    }
    
//////////////////////////////////////////////////////////////////////
    
    
    
    
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
                debugPrint(error)
//                Popup.instanse.showError("", message: error)
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
                    let Status = "Status"
                    let Data = "Data"
                    
                    guard let value = response.result.value else { return }
                    let json = JSON(value)
                    guard let errorCode = json[Status].int else { return }
                    
                    if errorCode == 200 || errorCode == 500 {
                        completion(Result.Response(json[Data]))
                    } else {
                        let errorDesc = errorDecription().getErrorName(errorCode)
                        completion(Result.Error(errorDesc))
                    }
                case .Failure(let error):
                    completion(Result.Error(error.localizedDescription))
                }
        }
    }
}
