//
//  Model.swift
//  first
//
//  Created by gvantsa gvagvalia on 7/21/23.
//

import Foundation

struct CurrentWeather: Codable {
    let coord: Coordinates
    let weather: [CurrentWeatherArray]
    let main: MainData
    let wind: WindData
//    let dt: Int
    let sys: SysData
    let name: String
    
    struct CurrentWeatherArray: Codable {
        let main: String
        let description: String
        let icon: String
    }
    struct MainData: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Int
    }
    struct WindData: Codable {
        let speed: Double
    }
    struct Coordinates: Codable {
        let lon: Double
        let lat: Double
    }
    struct SysData: Codable {
        let country: String
    }

}


