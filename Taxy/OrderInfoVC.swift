//
//  OrderInfoVC.swift
//  Taxy
//
//  Created by iosdev on 25.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

class OrderInfoVC: UIViewController {
    
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverCarLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var driverImageLabel: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!

    var order = Order()
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "checkOrder", userInfo: nil, repeats: true)
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
    }
    
}

extension OrderInfoVC: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
//        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
//        addressLabel.lock()
//        
//        if (gesture) {
//            mapCenterPinImage.fadeIn(0.25)
//            mapView.selectedMarker = nil
//        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.name
            
            if let photo = placeMarker.place.photo {
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
//        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
//        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }

}