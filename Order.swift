//
//  Order.swift
//  Taxy
//
//  Created by Artem Valiev on 06.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//
import SwiftyJSON


class Order {
//    static let instanse = Order()
    var userID: String?
    var fromPlace: String?
    var toPlace: String?
    var orderType: OrderType = .City
    var comment: String?
    var price: Int?
    var isCab = false
    var isChildChair = false
    var moreInformation = false
    var coordinates: CLLocationCoordinate2D?
    var orderID: String?
    var driverInfo: UserProfile?
    var orderStatus: Int?
    var createdAt: NSDate?
}

enum OrderFields: String {
    case UserId, ServiceType, FromAddress, ToAddress, Longitude, Latitude, Price, Comment, WithChildChair, OrderType, Id, OrderStatus, Driver, City, CreatedAt
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
        
        
        // for
        
        for (_, orderInfo):(String, JSON) in json {

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
            if let driverInfo = orderInfo[OrderFields.Driver.rawValue].dictionary {
                order.driverInfo?.name = "some driver infos"
            } else {
                order.driverInfo?.name = "водитель еще не назначен"
            }
            if let createdAtString = orderInfo[OrderFields.CreatedAt.rawValue].string,
            let date = Helper().dateFromString(createdAtString)
            {
                order.createdAt = date
            }
            orders.append(order)
        }
        
        
        
        
        
        return orders
    }
    
}