//
//  ForecastModel.swift
//  first
//
//  Created by gvantsa gvagvalia on 7/22/23.
//

import Foundation

struct DetailedWeather: Codable {
    let list: [ListArray]
    let city: City
}

struct ListArray: Codable {
    let dt: Int
    let main: WeatherMain
    let weather: [WeatherArray]
    let sys: TimeOfTheDay
    let dt_txt: String
    
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dt_txt) else {
            return ""
        }
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
struct WeatherMain: Codable {
    let temp: Double
}

struct WeatherArray: Codable {
    let id: Int
    let description: String
    let icon: String
}
struct TimeOfTheDay: Codable {
    let pod: String
}
struct City: Codable {
    let name: String
    let country: String
}
