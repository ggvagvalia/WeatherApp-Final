//
//  ViewController.swift
//  first
//
//  Created by gvantsa gvagvalia on 7/21/23.
//

import UIKit
import CoreLocation
import MapKit

class TodayVC: UIViewController, CLLocationManagerDelegate {
    let mainView = UIView()
    var currentWeather: CurrentWeather?
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var highestTempLabel: UILabel!
    @IBOutlet weak var lowestTempLabel: UILabel!
 
    @IBOutlet weak var windImage: UIImageView!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var humidityImage: UIImageView!
    @IBOutlet weak var cloudCoverImage: UIImageView!
    @IBOutlet weak var highestTempImage: UIImageView!
    @IBOutlet weak var lowestTempImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTodaysWeather()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        location.text = ""
        temperature.text = ""
        wind.text = ""
        humidityLabel.text = ""
        cloudCoverLabel.text = ""
        highestTempLabel.text = ""
        lowestTempLabel.text = ""
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            getWeatherData(latitude: latitude, longitude: longitude)
            //          getWeatherData(latitude: 41.6938, longitude: 44.8015)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    func getWeatherData(latitude: Double, longitude: Double) {
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=41.6938&lon=44.8015&appid=f85f73a76a70699a5b4b531a115e1e99&units=metric") else { return }
        
                guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=f85f73a76a70699a5b4b531a115e1e99&units=metric") else { return }
        
        let urlReq = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReq) { data, response, error in
            
            if let data = data {
                do {
                    self.currentWeather = try JSONDecoder().decode(CurrentWeather.self, from: data)
                    
                    DispatchQueue.main.async {
                        if let weather = self.currentWeather {
                            let temperatureText = "\(weather.main.temp) °C | \(weather.weather[0].main)"
                            self.temperature.text = temperatureText
                            
                            if weather.main.temp <= 15 {
                                self.temperature.textColor = .systemBlue
                            } else {
                                self.temperature.textColor = .systemPink
                            }
                            
                            print(weather.main.temp_max)
                            print(weather.main.temp_min)
                            self.wind.text = "\(weather.wind.speed ) m/s"
                            self.humidityLabel.text = "\(weather.main.humidity)"
                            self.highestTempLabel.text = "\(weather.main.temp_max) °C"
                            self.lowestTempLabel.text = "\(weather.main.temp_min) °C"
                            self.cloudCoverLabel.text = "\(weather.weather[0].description)"
                            self.location.text = "\(self.currentWeather?.sys.country ?? "---") - \(self.currentWeather?.name ?? "---")"
                            
                        }
                    }
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
            
        }.resume()
    }
    func createTodaysWeather() -> UIView {
        
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        windImage.image = UIImage(systemName: "wind")
        tempImage.image = UIImage(systemName: "cloud.moon")
        humidityImage.image = UIImage(systemName: "humidity")
        cloudCoverImage.image = UIImage(systemName: "cloud.sun")
        highestTempImage.image = UIImage(systemName: "thermometer.sun.fill")
        lowestTempImage.image = UIImage(systemName: "thermometer.low")
        
        view.tintColor = .systemYellow

        return mainView
    }
}

