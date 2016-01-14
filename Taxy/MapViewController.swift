//
//  MapViewController.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import DrawerController
import SwiftLocation




class MapViewController: UIViewController {
    
    
    var initiator: String?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    private var coords: CLLocationCoordinate2D?
    
    var onSelected: ((address: String, coords: CLLocationCoordinate2D) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setupMenuButtons()
        mapView.delegate = self

    }
    
    deinit {
        print("\(__FUNCTION__)")
    }
    

    
    func setupMenuButtons() {
//        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
//        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: true)
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .Plain, target: self, action: "doneTouched")
        self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    

    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        
 
        SwiftLocation.shared.reverseCoordinates(Service.GoogleMaps, coordinates: coordinate, onSuccess: { (place) -> Void in
            self.addressLabel.unlock()

            guard let city = place?.locality, let street = place?.thoroughfare, let home = place?.subThoroughfare else {
                debugPrint("cant get city and street from place")
                return
            }
            self.addressLabel.text = city + ", " + street
            if home.characters.count > 0 {
                self.coords = coordinate
                self.addressLabel.text?.appendContentsOf(", \(home)")
            }
            let labelHeight = self.addressLabel.intrinsicContentSize().height + 10
            self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
            
            UIView.animateWithDuration(0.25) {
                self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                self.view.layoutIfNeeded()
            }
            
            
            }) { (error) -> Void in
                debugPrint(error)
        }

        
        
//        let geocoder = GMSGeocoder()
//        
//        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
//            self.addressLabel.unlock()
//            if let address = response?.firstResult() {
//                let street = address.thoroughfare
//                let city = address.locality
//                self.addressLabel.text = city + "\n" + street
//                let labelHeight = self.addressLabel.intrinsicContentSize().height
//                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
//                
//                UIView.animateWithDuration(0.25) {
//                    self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
    }
    
}


// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
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

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        addressLabel.lock()
        
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
//        guard let placeMarker = marker as? PlaceMarker else {
//            return nil
//        }
//        
//        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
//            infoView.nameLabel.text = placeMarker.place.name
//            
//            if let photo = placeMarker.place.photo {
//                infoView.placePhoto.image = photo
//            } else {
//                infoView.placePhoto.image = UIImage(named: "generic")
//            }
//            
//            return infoView
//        } else {
            return nil
//        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
    
    func doneTouched() {
        guard let text = addressLabel.text, let coordinates = coords else {
            return
        }
        onSelected?((address: text, coords: coordinates))

        navigationController?.popViewControllerAnimated(true)

    }
    
}