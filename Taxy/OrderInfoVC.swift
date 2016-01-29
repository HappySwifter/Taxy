//
//  OrderInfoVC.swift
//  Taxy
//
//  Created by iosdev on 25.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import CNPPopupController
import HCSStarRatingView
import SwiftLocation

final class OrderInfoVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverCarLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var driverImageLabel: UIImageView!
//    @IBOutlet weak var fromLabel: UILabel!
//    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var topGradientView: UIView!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var closeOrderButton: UIButton!

//    private let locationManager = CLLocationManager()

    var order = Order()
    var timer: NSTimer?
    var raiting: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.myLocationEnabled = true
//        do {
//           try SwiftLocation.shared.continuousLocation(.House, onSuccess: { (location) -> Void in
//                
//                }) { (error) -> Void in
//                     debugPrint(error)
//            }
//        }
//        catch (let ex) {
//            debugPrint(ex)
//        }
        
        
        
        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
        updateView()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "checkOrder", userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    deinit {
        debugPrint("\(__FUNCTION__): \(__FILE__)")
    }
    
    func checkOrder() {
        Networking.instanse.checkOrder(order) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
            case .Response(let orders):
                guard let order = orders.first else { return }
                self?.order = order
                self?.updateView()
            }
        }
    }
    
    
    func updateView() {
        if UserProfile.sharedInstance.type == .Passenger {
            titleLabel.text = "Водитель в пути"
            driverNameLabel.text = order.driverInfo.name
            driverCarLabel.text = order.driverInfo.carModel
            closeOrderButton.hidden = true
            cancelOrderButton.hidden = false
            
        } else {
            titleLabel.text = "Клиент ожидает"
            driverNameLabel.text = order.passengerInfo.name
            closeOrderButton.hidden = false
            cancelOrderButton.hidden = true
        }


        
        topGradientView.layer.mask = getGradientForView(topGradientView)
        bottomGradientView.layer.mask = getGradientForView(bottomGradientView, inverted: true)

        
        
        if !UIApplication.sharedApplication().canOpenURL(NSURL(string: "tel://")!) {
            callButton.hidden = true
        }
        
        
//        guard let coords = order.driverInfo.location?.coordinates else { return }
        guard let orderStatus = order.orderStatus else {
            dismissMe()
            return
        }
        
        if orderStatus == 3 {
            Popup.instanse.showInfo("Внимание", message: "Заказ отменен")
            dismissMe()
            return
        } else if orderStatus == 2 {
            timer?.invalidate()
            Popup.instanse.showSuccess("", message: "Заказ выполнен").handler { [weak self] _ in
                if UserProfile.sharedInstance.type == .Passenger {
                    self?.presentRate()
                    return
                }
            }
        }
        
        
        
        

        
//        var bounds = GMSCoordinateBounds()
        let location: Location?
        if UserProfile.sharedInstance.type == .Passenger {
            location = order.driverInfo.location
        } else {
            location = order.passengerInfo.location
        }
        if let location = location {
//            bounds = bounds.includingCoordinate(location.coordinates)
//            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 80))

            mapView.clear()
            let marker = PlaceMarker(coords: location.coordinates)
            marker.map = mapView
            
             mapView.camera = GMSCameraPosition(target: location.coordinates, zoom: 15, bearing: 0, viewingAngle: 0)
        } else {
            // если нет координат у оппонента, центруем карту на себе
            if let myLoc = mapView.myLocation {
                 mapView.camera = GMSCameraPosition(target: myLoc.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            }
           
        }

        
       

        
    }
    
    @IBAction func cancelOrderTouched() {
        guard order.driverInfo.userID != UserProfile.sharedInstance.userID else {
            Popup.instanse.showInfo("Вимание", message: "Водитель не может отменить заказ")
            return
        }
        Helper().showLoading("Отменяю заказ")
        Networking.instanse.cancelOrder(order) { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            default:
                break
            }
            self?.dismissMe()
        }
    }

    @IBAction func closeOrderTouched() {
        guard order.passengerInfo.userID != UserProfile.sharedInstance.userID else {
            Popup.instanse.showInfo("Вимание", message: "Пассажир не может завершить заказ")
            return
        }
        Helper().showLoading("Загрузка")
        Networking.instanse.closeOrder(order) { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                if UserProfile.sharedInstance.type == .Passenger {
                    self?.presentRate()
                } else {
                    self?.dismissMe()
                }
            }
        }
    }
    
    @IBAction func showInfoTouched() {
        performSegueWithIdentifier("ShowAditionalInfoSegue", sender: nil)
    }
    
    
    func dismissMe() {
//        self.timer?.invalidate()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getGradientForView(view : UIView, inverted: Bool = false) -> CAGradientLayer {
        let startColor: UIColor = UIColor.whiteColor()
        let endColor: UIColor = UIColor.clearColor()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = topGradientView.bounds;
        if inverted {
            gradientLayer.colors = [endColor.CGColor, startColor.CGColor, startColor.CGColor]
        } else {
            gradientLayer.colors = [startColor.CGColor, startColor.CGColor, endColor.CGColor]
        }
        gradientLayer.locations = [0.0, 0.3, 1.0]
        return gradientLayer
    }
}

extension OrderInfoVC: GMSMapViewDelegate {
//    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
//        reverseGeocodeCoordinate(position.target)
//    }
    
//    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
//        addressLabel.lock()
//        
//        if (gesture) {
//            mapCenterPinImage.fadeIn(0.25)
//            mapView.selectedMarker = nil
//        }
//    }
    
//    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
//        guard let placeMarker = marker as? PlaceMarker else {
//            return nil
//        }
//        
//        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
//            infoView.nameLabel.text = placeMarker.order.driverInfo.name
//            
//            if let photo = placeMarker.order.driverInfo.image {
//                infoView.placePhoto.image = photo
//            } else {
//                infoView.placePhoto.image = UIImage(named: "generic")
//            }
//            
//            return infoView
//        } else {
//            return nil
//        }
//    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapView.selectedMarker = marker;
        return true
    }
    
//    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
////        mapCenterPinImage.fadeIn(0.25)
//        mapView.selectedMarker = nil
//        return false
//    }
    
    
    func mapViewDidFinishTileRendering(mapView: GMSMapView!) {
        
    }
    


}

//extension OrderInfoVC: CLLocationManagerDelegate {
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedWhenInUse {
//            locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
//        }
//    }
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            
////            let bounds = GMSCoordinateBounds()
////            bounds.includingCoordinate(location.coordinate)
////            mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
//            
////            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//            locationManager.stopUpdatingLocation()
//        }
//    }
//}


extension OrderInfoVC: Rateble {
    func didRate(value: HCSStarRatingView) {
        print(value.value)
        raiting = Int(value.value)
    }
    func popupControllerDidDismiss() {
        guard let driverId = order.driverInfo.userID else {
            dismissMe()
            return
        }
        Networking.instanse.rateDriver(driverId, value: raiting)
        dismissMe()
    }
    
}