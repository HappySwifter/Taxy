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
    case LoadingSTID
    case LoginSTID
    case MySettingsSTID
    case MyOrdersSTID
    case MapSTID
    case MakeOrderSTID
    case TaxyRequestingSTID
    case RulesSTID
}


enum ServerMethods: String {
    case GetCities
    case GetCode
    case VerifyCode
    case GetUserInfo
    case UpdateProfile
    
    // orders
    case CreateOrder
    case GetOrders
    case CancelOrder
    case CheckOrder // инфа по определенному заказу (для мониторинга)
    case GetOnlyMyOrder // для водителя. Мониторит заказы для конкретного водителя, назначенные ему, как самому ближнему по расстоянию к пассажиру
    case СloseOrder
    case SendCoordinates

}

enum OrderType: String {
    case City
    case Intercity
    case Freight
    case Service
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


private enum Alert {
    case None, AtTime, Five, Thirty, Hour, Day, Week
    func title() -> String {
        switch self {
        case None: return "None"
        case AtTime: return "At time of event"
        case Five: return "5 minutes before"
        case Thirty: return "30 minutes before"
        case Hour: return "1 hour before"
        case Day: return "1 day before"
        case Week: return "1 week before"
        }
    }
    static func values() -> [Alert] {
        return [AtTime, Five, Thirty, Hour, Day, Week]
    }
}

