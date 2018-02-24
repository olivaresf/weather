//
//  OpenWeather.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation

enum OpenWeatherResponse<T> {
    case networkError(Error)
    case serverError(HTTPCode)
    case missingData
    case invalidData(Data)
    case success(T)
}

extension String : Error { }

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

class OpenWeather {
    
    static let api = API()
    
    static func getWeather(coordinate: (latitude: Float, longitude: Float), completion: @escaping (OpenWeatherResponse<WeatherData>) -> ()) {
        api.request(.weather(latitude: coordinate.latitude, longitude: coordinate.longitude)) { response in
            switch response {
                
            case .networkError(let error): completion(.networkError(error))
            case .expectedDataMissing: completion(.missingData)
            case .unexpectedHTTPCode(let unexpectedCode): completion(.serverError(unexpectedCode))
                
            case .success(let data):
                
                guard let result = try? WeatherData(data: data) else {
                    completion(.invalidData(data))
                    return
                }
                
                completion(.success(result))
            }
        }
    }
}
