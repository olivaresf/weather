//
//  WeatherData.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation

/// This class handles the parsing of querying OpenWeather for the weather in a certain location.
/// FIXME:
/// Unfortunately, I don't have enough experience with Codable to adopt it for this project (though I'm reading!)
/// This implementation, however, should be very modular and should be refactored using Codable in the future.
struct WeatherData {
    
    let temperature: (min: String, current: String, max: String)
    let forecast: String
    let name: String
    let image: URL
    
    init(data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let jsonDictionary = json as? [String: Any] else { throw "Unexpected JSON" }
        
        guard
            let temperatureDictionary = jsonDictionary["main"] as? [String: Float],
            let minTemp = temperatureDictionary["temp_min"],
            let currentTemp = temperatureDictionary["temp"],
            let maxTemp = temperatureDictionary["temp_max"]
            else {
                throw "JSON does not contain temperature information"
        }
        
        temperature = (min: String(format: "%.0f", minTemp),
                       current: String(format: "%.0f", currentTemp),
                       max: String(format: "%.0f", maxTemp))
        
        guard
            let forecastDictionary = jsonDictionary["weather"] as? [[String: Any]],
            let initialForecast = forecastDictionary.first,
            let description = initialForecast["description"] as? String,
            let icon = initialForecast["icon"] as? String else {
                throw "JSON does not contain forecast information"
        }
        
        forecast = description
        image = URL(string: "http://openweathermap.org/img/w/\(icon).png")!
        
        guard let locationName = jsonDictionary["name"] as? String else {
            throw "JSON does not contain location name"
        }
        
        name = locationName
    }
}
