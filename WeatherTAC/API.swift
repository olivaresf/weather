//
//  OpenWeather.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import Foundation

enum HTTPVerb: String {
    case GET
}

enum HTTPCode: Int {
    case OK = 200
    case Unauthorized = 401
    case ServerError = 500
}

enum APIEndpoint {
    case weather(latitude: Float, longitude: Float)
    
    var httpVerb: HTTPVerb {
        switch self {
        case .weather: return .GET
        }
    }
    
    var url: String {
        switch self {
        case .weather(let latitude, let longitude): return "/data/2.5/weather?lat=\(latitude)&lon=\(longitude)"
        }
    }
    
    var allowedHTTPCodes: [HTTPCode] {
        switch self {
        case .weather: return [.OK]
        }
    }
    
    var expectsData: Bool {
        switch self {
        case .weather: return true
        }
    }
}

enum APIResponse {
    case networkError(Error)
    case unexpectedHTTPCode(HTTPCode)
    case expectedDataMissing
    case success(Data)
}

class API {
    
    private static var session: URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        return URLSession(configuration: sessionConfiguration)
    }
    
    func request(_ endpoint: APIEndpoint, completion: @escaping (APIResponse) -> ()) {
        
        let baseURL = "api.openweathermap.org"
        let urlString = "https://\(baseURL)\(endpoint.url)&APPID=34309e034e2b1054ecfd7ee510b15b3b"
        let fullURL = URL(string: urlString)!
        
        let dataTask = API.session.dataTask(with: fullURL) { (possibleData, possibleResponse, possibleError) in
            
            // Check for network errors.
            guard possibleError == nil else {
                completion(.networkError(possibleError!))
                return
            }
            
            // Check for HTTP errors.
            if let response = possibleResponse,
                let httpResponse = response as? HTTPURLResponse,
                let httpCodeResponse = HTTPCode(rawValue: httpResponse.statusCode){
                
                guard endpoint.allowedHTTPCodes.contains(httpCodeResponse) else {
                    completion(.unexpectedHTTPCode(httpCodeResponse))
                    return
                }
            }
            
            guard endpoint.expectsData else {
                completion(.success(Data()))
                return
            }
            
            guard let data = possibleData else {
                completion(.expectedDataMissing)
                return
            }
            
            completion(.success(data))
        }
        
        dataTask.resume()
    }
}
