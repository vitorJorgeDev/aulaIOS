//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheatersMapViewController: UIViewController {

    // MARK: - Properties
    var elementName: String!
    var theater: Theater!
    var theaters: [Theater] = []
    lazy var locationManager = CLLocationManager()
    var poiAnnotations: [MKPointAnnotation] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        self.loadXML()
        requestLocation()
    }
    
    // MARK: - Methods
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            switch CLLocationManager.authorizationStatus() {
                case .authorizedWhenInUse, .authorizedAlways:
                    print("Usuário já autorizou!")
                    monitorUserLocation()
                case .notDetermined:
                    print("Usuário ainda não autorizou")
                    locationManager.requestWhenInUseAuthorization()
                case .denied:
                    print("Usuário negou autorização!")
                case .restricted:
                    print("O acesso ao GPS está bloqueado nesse device")
            }
        }
    }
    
    func loadXML() {
        if let xmlURL = Bundle.main.url(forResource: "theaters.xml", withExtension: nil), let xmlParser = XMLParser(contentsOf: xmlURL) {
            xmlParser.delegate = self
            xmlParser.parse()
        }
    }
    
    func addTheatersToMap() {
        for theater in theaters {
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            //let annotation = MKPointAnnotation()
            let annotation = TheaterAnnotation(coordinate: coordinate)
            //annotation.coordinate = coordinate
            annotation.title = theater.name
            annotation.subtitle = theater.url
            mapView.addAnnotation(annotation)
        }
        
        //Definindo região a ser mostrada
        /*
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: -23.5694836, longitude: -46.6467494), 2000, 2000)
        mapView.setRegion(region, animated: true)
        */
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func monitorUserLocation() {
        //locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
    }
    
    func getRoute(destination: CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        let directions = MKDirections(request: request)
        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if error == nil {
                guard let response = response else {return}
                let route = response.routes.first!
                print("Nome:", route.name)
                print("Distância:", route.distance)
                print("Duração:", route.expectedTravelTime)
                
                for step in route.steps {
                    print("Em \(step.distance) metros, \(step.instructions)")
                }
                
                //DispatchQueue.main.async {
                    self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                //}
                
                
            }
        }
    }

}

// MARK: - XMLParserDelegate
extension TheatersMapViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.elementName = elementName
        if elementName == "Theater" {
            theater = Theater()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty {
            switch elementName {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "url":
                theater.url = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Theater" {
            theaters.append(theater)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Total de cinemas:", theaters.count)
        addTheatersToMap()
    }
}

// MARK: - MKMapViewDelegate
extension TheatersMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer  = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            renderer.lineWidth = 6.0
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        if annotation is MKPinAnnotationView {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "TheaterPin")
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TheaterPin")
                (annotationView as! MKPinAnnotationView).canShowCallout = true
                (annotationView as! MKPinAnnotationView).pinTintColor = .blue
                (annotationView as! MKPinAnnotationView).animatesDrop = true
            } else {
                annotationView?.annotation = annotation
            }
        } else if annotation is TheaterAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "theaterIcon")
                let btLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                btLeft.setImage(UIImage(named: "car"), for: .normal)
                annotationView.leftCalloutAccessoryView = btLeft
                let btRight = UIButton(type: UIButtonType.detailDisclosure)
                annotationView.rightCalloutAccessoryView = btRight
            } else {
                annotationView?.annotation = annotation
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            print("Traçando rota!")
            getRoute(destination: view.annotation!.coordinate)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.url = view.annotation!.subtitle!
            present(vc, animated: true, completion: nil)
        }
        mapView.removeOverlays(mapView.overlays)
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension TheatersMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("Acabou de autorizar!!!")
                monitorUserLocation()
            default:
                break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("userLocation:", userLocation.location!.speed)
//        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
//        mapView.setRegion(region, animated: true)
    }
}


// MARK: - UISearchBarDelegate
extension TheatersMapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response: MKLocalSearchResponse?, error: Error?) in
            if error == nil {
                guard let response = response else {return}
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.poiAnnotations)
                    self.poiAnnotations.removeAll()
                    for item in response.mapItems {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        annotation.subtitle = item.phoneNumber
                        self.poiAnnotations.append(annotation)
                    }
                    self.mapView.addAnnotations(self.poiAnnotations)
               }
            }
            searchBar.resignFirstResponder()
        }
    }
}


















