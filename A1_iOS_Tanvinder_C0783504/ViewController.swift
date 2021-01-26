//
//  ViewController.swift
//  A1_iOS_Tanvinder_C0783504
//
//  Created by user191496 on 1/26/21.
//

import UIKit
import MapKit
class ViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!

    var Loc: CLLocation?
    var manger = CLLocationManager()
    var pin = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manger.requestWhenInUseAuthorization()
        manger.delegate = self
        manger.startUpdatingLocation()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(Tap(_:)))
        map.addGestureRecognizer(tapGR)
    }
    
    
    @objc func Tap(_ gesture: UITapGestureRecognizer){
        let touch = gesture.location(in: map)
        let tapLoc = map.convert(touch, toCoordinateFrom: map)
            var title = String()
          if map.annotations.count == 0{
                title = "A"
            }
            else if map.annotations.count == 1{
                title = "B"
            }
            else{
                title = "C"
            }
        
        
        /*Switch (map.annotation.count)
        {
            Case1:
                title = "A";
        break;
            Case2:
            title = "B";
            break;
            Default:
            title = "C";
            
        }*/
        
        if let nearbyLoc = map.annotations.closest(to: CLLocation(latitude: tapLoc.latitude, longitude: tapLoc.longitude)){
            map.removeAnnotation(nearbyLoc)
            for overlay in map.overlays{
                map.removeOverlay(overlay)
            }
        }
        else{
            if map.annotations.count <= 2{
                let annotation  = MKPointAnnotation()
                annotation.title = title
                annotation.coordinate = tapLoc
                map.addAnnotation(annotation)
                if map.annotations.count == 3{
                    let polygon = MKPolygon(coordinates: map.annotations.map({$0.coordinate}), count: 3)
                    map.addOverlay(polygon)
                }
            }
            else{
                for overlay in map.overlays{
                    map.removeOverlay(overlay)
                }
                for pin in map.annotations{
                    map.removeAnnotation(pin)
                }
            }
        }
    }
    
       
    
    @IBAction func directBtn(_ sender: Any) {
        if map.annotations.count == 3{
            let crArr = map.annotations.map({$0.coordinate})
            for overlay in map.overlays{
                map.removeOverlay(overlay)
            }
            let dirReq = MKDirections.Request()
            dirReq.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[0].latitude, longitude: crArr[0].longitude), addressDictionary: nil))
            dirReq.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[1].latitude, longitude: crArr[1].longitude), addressDictionary: nil))
            dirReq.requestsAlternateRoutes = true
            dirReq.transportType = .automobile
            
            let dr = MKDirections(request: dirReq)
            dr.calculate { (re, err) in
                if err == nil{
                    if let route = re!.routes.first {
                        self.map.addOverlay(route.polyline)
                        self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[1].latitude, longitude: crArr[1].longitude), addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[2].latitude, longitude: crArr[2].longitude), addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .automobile
            
            let Dir = MKDirections(request: request)
            Dir.calculate { (re, err) in
                if err == nil{
                    if let route = re!.routes.first {
                        self.map.addOverlay(route.polyline)
                        self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
                let Req = MKDirections.Request()
                Req.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[2].latitude, longitude: crArr[2].longitude), addressDictionary: nil))
                Req.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: crArr[0].latitude, longitude: crArr[0].longitude), addressDictionary: nil))
                Req.requestsAlternateRoutes = true
                Req.transportType = .automobile
                
                
                let direc = MKDirections(request: Req)
                direc.calculate { (re, err) in
                    if err == nil{
                        if let route = re!.routes.first {
                            self.map.addOverlay(route.polyline)
                            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                }
            }
   
             
        
        }
  

}
extension ViewController : MKMapViewDelegate,CLLocationManagerDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if  overlay is MKPolygon{
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red
            rendrer.strokeColor = UIColor.green
            rendrer.alpha = 0.5
            return rendrer
        }
        else if overlay is MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.lineWidth = 4
            rendrer.strokeColor = UIColor.purple
            return rendrer
        }
        return MKOverlayRenderer(overlay: overlay)

    
    
    
    }



    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "A":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            let lbl = UILabel()
            let user = CLLocation(latitude:  mapView.userLocation.coordinate.latitude, longitude:  mapView.userLocation.coordinate.longitude)
            let a =  CLLocation(latitude:  annotation.coordinate.latitude, longitude:  annotation.coordinate.longitude)
            let distance = user.distance(from: a)
            lbl.text = "Distance is \(distance.rounded())"
            annotationView.detailCalloutAccessoryView = lbl
            annotationView.markerTintColor = UIColor.blue
            annotationView.canShowCallout = true
            return annotationView
            
        case "B":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            let lbl = UILabel()
            let user = CLLocation(latitude:  mapView.userLocation.coordinate.latitude, longitude:  mapView.userLocation.coordinate.longitude)
            let b =  CLLocation(latitude:  annotation.coordinate.latitude, longitude:  annotation.coordinate.longitude)
            let distance = user.distance(from: b)
            lbl.text = "Distance is \(distance.rounded())"
            annotationView.detailCalloutAccessoryView = lbl
            annotationView.markerTintColor = UIColor.blue
            annotationView.canShowCallout = true
            return annotationView
            
        case "C":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            let lbl = UILabel()
            let user = CLLocation(latitude:  mapView.userLocation.coordinate.latitude, longitude:  mapView.userLocation.coordinate.longitude)
            let c =  CLLocation(latitude:  annotation.coordinate.latitude, longitude:  annotation.coordinate.longitude)
            let distance = user.distance(from: c)
            lbl.text = "Distance is \(distance.rounded()) "
            annotationView.detailCalloutAccessoryView = lbl
            annotationView.markerTintColor = UIColor.blue
            annotationView.canShowCallout = true
            return annotationView
        
        default:
            return nil
        }
    }

  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {return}
       Loc = loc
        map.region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
}



   extension Array where Iterator.Element == MKAnnotation {
            
            func closest(to fixedLocation: CLLocation) -> Iterator.Element? {
                guard !self.isEmpty else { return nil}
                var closestAnnotation: Iterator.Element? = nil
                var smallestDistance: CLLocationDistance = 5000
                for annotation in self {
                    let locationForAnnotation = CLLocation(latitude: annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                    let distanceFromUser = fixedLocation.distance(from:locationForAnnotation)
                    if distanceFromUser < smallestDistance {
                        smallestDistance = distanceFromUser
                        closestAnnotation = annotation
                    }
                }
                return closestAnnotation
            }
        }
