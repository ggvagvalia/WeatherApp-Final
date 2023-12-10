//
//  ForecastVC.swift
//  first
//
//  Created by gvantsa gvagvalia on 7/22/23.
//

import UIKit
import CoreLocation
import MapKit

class ForecastVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var detailedWeatherTableView: UITableView!
    @IBOutlet weak var forecastLocationLabel: UILabel!
    
    var forecastModel: DetailedWeather?
    
    var groupedWeatherData: [String: [ListArray]] = [:]
    var hourlyWeatherData: [String: [ListArray]] = [:]
    var locationManager = CLLocationManager()
    var weatherIcons: [String: String] = [
        "01d": "01d",
        "02d": "02d",
        "03d": "03d",
        "04d": "04d",
        "09d": "09d",
        "10d": "10d",
        "11d": "11d",
        "13d": "13d",
        "50d": "50d",
        "01n": "01n",
        "02n": "02n",
        "03n": "03n",
        "04n": "04n",
        "09n": "09n",
        "10n": "10n",
        "11n": "11n",
        "13n": "13n",
        "50n": "50n",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedWeatherTableView.dataSource = self
        detailedWeatherTableView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //        getWeatherData()
    }
    
    func getSortedDaysOfWeek() -> [String] {
        let dateFormatter = DateFormatter()
        let currentDay = Calendar.current.component(.weekday, from: Date())
        var weekdaySymbols = dateFormatter.weekdaySymbols
        
        let prefixIndex = currentDay - 1
        weekdaySymbols = Array(weekdaySymbols!.suffix(from: prefixIndex)) + Array(weekdaySymbols!.prefix(upTo: prefixIndex))
        
        return weekdaySymbols!
    }
   
    func getWeatherData(latitude: Double, longitude: Double) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=f85f73a76a70699a5b4b531a115e1e99&units=metric") else { return }
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=41.6938&lon=44.8015&appid=f85f73a76a70699a5b4b531a115e1e99&units=metric") else { return }

        let urlReq = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReq) { data, response, error in
            
            if let error = error {
                print("error while fetching weather data: \(error)")
                return
            }
            
            do {
                guard let data = data else {
                    print("data is nil")
                    return
                }
                let weatherModel = try JSONDecoder().decode(DetailedWeather.self, from: data)
                var groupedWeatherByDay: [String: [ListArray]] = [:]
                
                for weatherData in weatherModel.list {
                    let dayOfWeek = weatherData.dayOfWeek
                    if var weatherArray = groupedWeatherByDay[dayOfWeek] {
                        weatherArray.append(weatherData)
                        groupedWeatherByDay[dayOfWeek] = weatherArray
                    } else {
                        groupedWeatherByDay[dayOfWeek] = [weatherData]
                    }
                }
                
                self.groupedWeatherData = groupedWeatherByDay
                self.forecastModel = weatherModel
                
                DispatchQueue.main.async {
                    self.detailedWeatherTableView.reloadData()
                    self.forecastLocationLabel.text = "\(self.forecastModel?.city.country ?? "----") - \(self.forecastModel?.city.name ?? "---")"
                }
                
            } catch {
                print("error")
            }
        }.resume()
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
}

extension ForecastVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedWeatherData.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedDays = getSortedDaysOfWeek()
        if section < sortedDays.count {
            let sectionDate = sortedDays[section]
            return groupedWeatherData[sectionDate]?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForecastVCCell
        let sortedDays = getSortedDaysOfWeek()
        
        if indexPath.section < sortedDays.count {
            let sectionDate = sortedDays[indexPath.section]
            if let weatherDataForSection = groupedWeatherData[sectionDate], indexPath.row < weatherDataForSection.count {
                let weatherData = weatherDataForSection[indexPath.row]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = dateFormatter.date(from: weatherData.dt_txt) {
                    dateFormatter.dateFormat = "HH:mm"
                    let hour = dateFormatter.string(from: date)
                    cell.timeLabel?.text = hour
                }
                
                cell.temperatureLabel?.text = "\(weatherData.main.temp)°C"
                let weatherDescription = weatherData.weather[0].description
                cell.descriptionLabel.text = weatherDescription
                
                let iconKey = weatherData.weather[0].icon
                if let iconName = weatherIcons[iconKey] {
                    cell.iconImage.image = UIImage(named: iconName)
                } else {
                    cell.iconImage.image = UIImage(systemName: "sparkles")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedDays = getSortedDaysOfWeek()
        if section < sortedDays.count {
            return sortedDays[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

