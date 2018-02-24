//
//  OpenWeather.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation

/// OpenWeather is our business logic class. This class doesn't technically deal with any networking code itself.
/// This class is, instead, an abstraction of all the things that can happen right before and right after a networking call.
/// It will make sure that the parameters for the call are all there before passing it along, and it will make sure that the response can be parsed.
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

/// The response from querying the OpenWeather API can have different results.
///
/// - networkError: foundation URL class couldn't complete the call
/// - serverError: the call could be completed, but the server returned an unexpected error (this can be a 4xx or 5xx error)
/// - missingData: the call was completed with a correct HTTP code but data was not there when it was expected to be
/// - invalidData: the call was completed with a correct HTTP code but data was invalid
/// - success: the call was completed successfuly and the data parsed.
enum OpenWeatherResponse<T> {
    case networkError(Error)
    case serverError(HTTPCode)
    case missingData
    case invalidData(Data)
    case success(T)
}

extension String : Error { }
