//
//  Constants.swift
//  Taxy
//
//  Created by iosdev on 10.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

let Status = "Status"
let Data = "Data"

let mainUrl = "http://yakuttaxi.azurewebsites.net/"


enum STID: String {
    case MenuSTID
    case LoadingSTID
    case LoginSTID
    case MySettingsSTID
    case MyOrdersSTID
    case FindOrdersSTID
    case MapSTID
    case MakeOrderSTID
    case TaxyRequestingSTID
    case RulesSTID
    case RateSTID
}


enum ServerMethods: String {
    case GetCities
    case GetCode
    case VerifyCode
    case GetUserInfo
    case UpdateProfile
    case SetDriverState // 1 - свободен, 2 - занят
    case Rate
    // orders
    case CreateOrder
    case GetOrders
    case FindOrders // поиск заказов для водителя
    case CancelOrder
    case CheckOrder // инфа по определенному заказу (для мониторинга)
    case GetOnlyMyOrder // для водителя. Мониторит заказы для конкретного водителя, назначенные ему, как самому ближнему по расстоянию к пассажиру
    case CloseOrder
    case SendCoordinates
    case AcceptOrder
    case RejectOrder // для отмены водителем автоназначаемого заказа
}

enum OrderType {
    case City, Intercity, Freight, Service
    func title() -> String {
        switch self {
        case City: return "Такси по городу"
        case Intercity: return "Такси межгород"
        case Freight: return "Грузовое такси"
        case Service: return "Услуги"
        }
    }
    static func value() -> [OrderType] {
        return [City, Intercity, Freight, Service]
    }
}




enum ServiceType: String {
    case Economic
    case Comfortable
    case Business
}

struct errorDecription {
    func getErrorName(code: Int) -> String {
        switch code {
        case 200:
            return "Нет ошибок"
        case 500:
            return "Ошибка сервера"
        case 405:
            return "Неверный СМС-код"
        case 406:
            return "Заказ не найден"
        case 404:
            return "Пользователь не найден"
        case 500:
            return "Ошибка сервера"
        case 501:
            return "Неверный формат телефона"
        case 502:
            return "Пользователь не найден"
        case 503:
            return "На балансе недостаточно денег"
        case 504:
            return "Операция запрещена"
        case 505:
            return "Пользователь неактивен"
        case 506:
            return "Сообщение уже отправлено"
        case 507:
            return "Такой пользователь уже существует"
        case 508:
            return "Поле откуда пустое"
        case 509:
            return "Поле куда пустое"
        case 510:
            return "Не заполнено поле цены"
        case 511:
            return "Заказ уже принят"
        case 512:
           return "Сообщение уже отправлено, запросите новое позже"
        default:
            return "Неопознанная ошибка"
        }
    }
}

enum Result<T, U> {
    case Response (T)
    case Error (U)
}



