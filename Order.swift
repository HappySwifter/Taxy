//
//  Order.swift
//  Taxy
//
//  Created by Artem Valiev on 06.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//
import SwiftyJSON


class Order {
    var userID: String?
    var fromPlace: String?
    var toPlace: String?
    var orderType: OrderType = .City
    var comment: String?
    var price: Int?
    var isCab = false
    var isChildChair = false
    var moreInformation = false
    var fromPlaceCoordinates: CLLocationCoordinate2D?
    var orderID: String?
    var driverInfo = UserProfile()
    var passengerInfo = UserProfile()

    var orderStatus: Int?
    var createdAt: NSDate?
}

enum OrderFields: String {
    case UserId, ServiceType, FromAddress, ToAddress, Longitude, Latitude, Price, Comment, WithChildChair, OrderType, Id, OrderStatus, Driver, City, CreatedAt, User, FromLatitude, FromLongitude
}

extension Order {
    func getOrderIDFromResponse(json: JSON) -> String? {
        if let orderID = json[OrderFields.Id.rawValue].string {
            return orderID
        } else {
            return nil
        }
    }
    
    func getOrderStatusFromResponse(json: JSON) -> Int? {
        if let orderStatus = json[OrderFields.OrderStatus.rawValue].int {
            return orderStatus
        } else {
            return nil
        }
    }
    
    func getOrdersFomResponse(json: JSON) -> [Order] {
        var orders = [Order]()
        
        
        
        func parseDict(orderInfo: JSON) -> Order {
            let order = Order()
            
            if let fromPlace = orderInfo[OrderFields.FromAddress.rawValue].string {
                order.fromPlace = fromPlace
            }
            if let toPlace = orderInfo[OrderFields.ToAddress.rawValue].string {
                order.toPlace = toPlace
            }
            if let orderID = orderInfo[OrderFields.Id.rawValue].string {
                order.orderID = orderID
            }
            if let passengerID = orderInfo[OrderFields.UserId.rawValue].string {
                order.userID = passengerID
            }
            if let price = orderInfo[OrderFields.Price.rawValue].int {
                order.price = price
            }
            if let price = orderInfo[OrderFields.Price.rawValue].int {
                order.price = price
            }
            if let orderStatus = orderInfo[OrderFields.OrderStatus.rawValue].int {
                order.orderStatus = orderStatus
            }
            if let createdAtString = orderInfo[OrderFields.CreatedAt.rawValue].string,
                let date = createdAtString.dateFromString()// Helper().dateFromString(createdAtString)
            {
                order.createdAt = date
            }
            
            if let userDict = orderInfo[OrderFields.User.rawValue].dictionary {
                order.passengerInfo = UserProfile().getModelFromDict(userDict, shared: false)
            }
            if let driverInfo = orderInfo[OrderFields.Driver.rawValue].dictionary {
                order.driverInfo = UserProfile().getModelFromDict(driverInfo, shared: false)
            } else {
                order.driverInfo.name = "водитель еще не назначен"
            }
            return order
        }
        
        if let _ = json.array {
            for (_, orderInfo):(String, JSON) in json {
                orders.append(parseDict(orderInfo))
            }
            return orders
        }
        
        if let _ = json.dictionary {
            return [parseDict(json)]
        }

        return []
    }
    
}