//
//  WeatherAnnotationView.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation
import MapKit

class WeatherAnnotationView : MKAnnotationView {
    init(annotation: WeatherAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: nil)
        
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        guard let contentView = WeatherAnnotationViewContent.loadFromNib() else { return }
        contentView.frame = CGRect(x: -21, y: -45, width: 100, height: 80)
        contentView.weatherForecast.text = annotation.data.forecast
        contentView.weatherTemperature.text = "\(annotation.data.temperature.current)"
        addSubview(contentView)
        
        calloutOffset = CGPoint(x: 0, y: 80)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WeatherAnnotationViewContent: UIView {
    @IBOutlet var weatherForecast: UILabel!
    @IBOutlet var weatherTemperature: UILabel!
    
    class func loadFromNib() -> WeatherAnnotationViewContent? {
        return self.loadFromNib(withName: "WeatherAnnotationView")
    }
}

extension UIView {
    class func loadFromNib<T>(withName nibName: String) -> T? {
        let nib  = UINib.init(nibName: nibName, bundle: nil)
        let nibObjects = nib.instantiate(withOwner: nil, options: nil)
        for object in nibObjects {
            if let result = object as? T {
                return result
            }
        }
        return nil
    }
}
