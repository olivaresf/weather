//
//  ViewController.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // As per the requirements:
        // > A second screen which will be opened when the user double-taps on a location
        // Since the mapview already has double-tap enabled to zoom in, we'll disable it first and then add our own double tap gesture.
        if let mapViewWithGestureRecognizers = mapView.subviews.first,
            let mapGestureRecognizers = mapViewWithGestureRecognizers.gestureRecognizers {
            
            // We're looking for a double-tap recognizer. Leave all others alone.
            for recognizer in mapGestureRecognizers {
                guard let doubleTapGestureRecognizer = recognizer as? UITapGestureRecognizer,
                    doubleTapGestureRecognizer.numberOfTapsRequired == 2 else { continue }
                
                mapViewWithGestureRecognizers.removeGestureRecognizer(doubleTapGestureRecognizer)
            }
            
            // Now add our own.
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showWeather(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            mapViewWithGestureRecognizers.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
    
    @objc func showWeather(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let point = tapGestureRecognizer.location(in: mapView)
        let tapPoint = mapView.convert(point, toCoordinateFrom: view)
        let latitude = Float(tapPoint.latitude)
        let longitude = Float(tapPoint.longitude)
        OpenWeather.getWeather(coordinate: (latitude: latitude, longitude: longitude)) { response in
            switch response {
            case .invalidData, .missingData, .networkError, .serverError:
                print("Error fetching forecast: \(response)")
                break
                
            case .success(let weatherData):

                // Add a new annotation representing this area.
                let annotation = WeatherAnnotation(data: weatherData)
                annotation.coordinate = tapPoint
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        guard let weatherAnnotation = annotation as? WeatherAnnotation else { return nil }
        
        return WeatherAnnotationView(annotation: weatherAnnotation, delegate: self)
    }
}

extension ViewController : WeatherAnnotationViewDelegate {
    func userDidTap(view: WeatherAnnotationView) {
        let detailVC = WeatherDetail.newFromStoryboard(weather: view.weatherData)
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true, completion: nil)
    }
}
