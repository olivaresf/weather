//
//  WeatherAnnotation.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation
import MapKit

class WeatherAnnotation : MKPointAnnotation {
    let data: WeatherData
    
    init(data: WeatherData) {
        self.data = data
    }
}
