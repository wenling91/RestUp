//
//  MapViewController.swift
//  RestUp
//
//  Created by NDHU_CSIE on 2020/12/31.
//  Copyright © 2020 NDHU_CSIE. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var hotel: HotelMO!
    
    let locationManager = CLLocationManager()
    var currentLocation: MKUserLocation?
    var targetPlacemark: CLPlacemark?
    
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request for a user's authorization for location services
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        //locationManager.delegate = self
        
        // Configure map view
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(hotel.location ?? "", completionHandler: { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                self.targetPlacemark = placemark
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.hotel.name
                annotation.subtitle = self.hotel.type
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
            
        })
    }
    
    
    // MARK: - Map View Delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyMarker"
        
        if annotation.isKind(of: MKUserLocation.self) {  //unchanged to the marker of the current location
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        //annotationView?.glyphText = "😋"
        // annotationView?.markerTintColor = UIColor.orange
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
        if let hotelImage = hotel.image {
            leftIconView.image = UIImage(data: hotelImage as Data)
        }
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    
    @IBAction func showDirection(_ sender: Any) {
        
        var currentPlacemark: CLPlacemark?
        //get the current location
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.requestLocation()  //request once
        
        guard let currentLocation = currentLocation?.location,
              let targetPlacemark = targetPlacemark else {
            return
        }
        
        let directionRequest = MKDirections.Request()
        
        // Set the source and destination of the route
        //directionRequest.source = MKMapItem.forCurrentLocation()
        //translate the current cooridinate to the address
        CLGeocoder().reverseGeocodeLocation(currentLocation) { places, _ in
            if let firstPlace = places?.first {
                currentPlacemark = firstPlace
                
                let sourcePlacemark = MKPlacemark(placemark: currentPlacemark!)
                directionRequest.source = MKMapItem(placemark: sourcePlacemark)
                let destinationPlacemark = MKPlacemark(placemark: targetPlacemark)
                directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
                directionRequest.transportType = self.currentTransportType
                
                // Calculate the direction
                let directions = MKDirections(request: directionRequest)
                
                directions.calculate { (routeResponse, routeError) -> Void in
                    
                    guard let routeResponse = routeResponse else {
                        if let routeError = routeError {
                            print("Error: \(routeError)")
                        }
                        return
                    }
                    
                    let route = routeResponse.routes[0]
                    self.currentRoute = route
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        currentLocation = userLocation
    }
    
    // MARK: - Location Manager Delegate methods
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error happen: \(error.localizedDescription)")
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            //translate the cooridinate to the address
//            CLGeocoder().reverseGeocodeLocation(location) { places, _ in
//                if let firstPlace = places?.first {
//                    self.currentPlacemark = firstPlace
//                }
//            }
//        }
//    }
    
}
