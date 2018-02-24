//
//  WeatherDetail.swift
//  WeatherTAC
//
//  Created by Fernando Olivares on 24/Feb/18.
//  Copyright © 2018 Fernando Olivares. All rights reserved.
//

import UIKit

class WeatherDetail : UITableViewController {
    
    var weather: WeatherData!
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    class func newFromStoryboard(weather: WeatherData) -> WeatherDetail {
        let storyboard = UIStoryboard(name: "WeatherDetail", bundle: nil)
        let weatherDetailVC = storyboard.instantiateInitialViewController() as! WeatherDetail
        weatherDetailVC.weather = weather
        return weatherDetailVC
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDetailCell", for: indexPath)
        
        let text: String
        let detail: String
        
        // FIXME: Unfortunately, due to time constraints, I couldn't make this more modular.
        // I'd love to create an enum and make this case exhaustive without a `default`.
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            detail = "Location"
            text = weather.name
            
        case (0, 1):
            detail = "Forecast"
            text = weather.forecast
            
        case (1, 0):
            detail = "Minimum"
            text = "\(weather.temperature.min)"
            
        case (1, 1):
            detail = "Current"
            text = "\(weather.temperature.current)"
            
        case (1, 2):
            detail = "Maximum"
            text = "\(weather.temperature.max)"
            
        default:
            text = ""
            detail = ""
            break
        }
        
        cell.detailTextLabel?.text = detail
        cell.textLabel?.text = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Location"
        case 1: return "Temperature"
        default: return nil
        }
    }
}
