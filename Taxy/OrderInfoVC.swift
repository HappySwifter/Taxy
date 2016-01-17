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

class OrderInfoVC: UIViewController {
    
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverCarLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var driverImageLabel: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!

    private let locationManager = CLLocationManager()

    var order = Order()
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        updateView()
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "checkOrder", userInfo: nil, repeats: true)
        timer!.fire()
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
        driverNameLabel.text = order.driverInfo.name
        driverCarLabel.text = "машина"
        
        if let price = order.price {
            priceLabel.text = String(price)
        }
        
        if let driverImage = order.driverInfo.image {
            driverImageLabel.hidden = false
            driverImageLabel.image = driverImage
        } else {
            driverImageLabel.hidden = true
        }
        if let fromPlace = order.fromPlace {
            fromLabel.text = fromPlace
        }
        if let toPlace = order.toPlace {
            toLabel.text = toPlace
        }
        
        let marker = PlaceMarker(place: order)
        marker.map = mapView
    }
    
    @IBAction func cancelOrderTouched() {
        Networking.instanse.cancelOrder(order) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            default:
                break
            }
            self?.timer?.invalidate()
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }

    @IBAction func closeOrderTouched() {
        Networking.instanse.closeOrder(order) { [weak self] result in
            switch result {
            case .Error(let error):
                Popup.instanse.showError("Внимание!", message: error)
            case .Response(_):
                self?.presentRate()
            }

        }
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
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.driverInfo.name
            
            if let photo = placeMarker.place.driverInfo.image {
                infoView.placePhoto.image = photo
            } else {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapView.selectedMarker = marker;
        return true
    }
    
//    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
////        mapCenterPinImage.fadeIn(0.25)
//        mapView.selectedMarker = nil
//        return false
//    }

}

extension OrderInfoVC: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}


extension OrderInfoVC: Rateble {
    func didRate(value: AnyObject) {
        if let value = value as? HCSStarRatingView {
            print(value.value)
        }
    }
    
    func popupControllerDidDismiss() {
        self.timer?.invalidate()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}