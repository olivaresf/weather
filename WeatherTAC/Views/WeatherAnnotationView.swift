//
//  WeatherAnnotationView.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation
import MapKit

protocol WeatherAnnotationViewDelegate {
    func userDidTap(view: WeatherAnnotationView)
}

class WeatherAnnotationView : MKAnnotationView {
    
    let delegate: WeatherAnnotationViewDelegate
    let weatherData: WeatherData
    
    init(annotation: WeatherAnnotation, delegate: WeatherAnnotationViewDelegate) {
        self.delegate = delegate
        weatherData = annotation.data
        
        super.init(annotation: annotation, reuseIdentifier: nil)
        
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        guard let contentView = WeatherAnnotationViewContent.loadFromNib() else { return }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didSelect))
        contentView.addGestureRecognizer(recognizer)
        
        contentView.frame = CGRect(x: -21, y: -45, width: 100, height: 80)
        contentView.weatherForecast.text = annotation.data.forecast
        contentView.weatherTemperature.text = "\(annotation.data.temperature.current)"
        addSubview(contentView)
        
        calloutOffset = CGPoint(x: 0, y: 80)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView != nil {
            superview?.bringSubview(toFront: self)
        }

        return hitView
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var inside = !bounds.contains(point)
        if !inside {
            for view in subviews {
                inside = view.frame.contains(point)
                guard !inside else { return true }
            }
        }

        return inside
    }
    
    @objc func didSelect() {
        delegate.userDidTap(view: self)
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
