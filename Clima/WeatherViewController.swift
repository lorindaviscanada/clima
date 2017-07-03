//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let APP_ID = "d60686e99caaa867bea48aa34888d4fa"
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherData = WeatherDataModel()
    
    var unitOfMesaure : String = "C"
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      loadCurrentLocationWeather()
    }
    
    
    func loadCurrentLocationWeather() {
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print ("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData (json: weatherJSON)
                
            }
            else {
                print ("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Error"
            }
        }
        
    }
    
    
    @IBAction func changeUnitOfMeasure(_ sender: UISwitch) {
        if sender.isOn {
            unitOfMesaure = "C"
            updatUIWithWeatherData()
        }
        else {
            unitOfMesaure = "F"
            updatUIWithWeatherData()
        }
        
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON) {
        
        if let temperature = json["main"]["temp"].double {
            weatherData.temperature = temperature
            weatherData.city = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            
            updatUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }

    }

    
    
    @IBAction func getCurrentCityWeather(_ sender: UIButton) {
        loadCurrentLocationWeather()
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updatUIWithWeatherData () {
        cityLabel.text = weatherData.city
        temperatureLabel.text = getTempInPerferedUnits(temperature: weatherData.temperature)
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
    }
    
    func getTempInPerferedUnits(temperature : Double) -> String {
        if unitOfMesaure == "C" {
            return "\(Int(temperature - 273.15)) ℃"
        }
        else {
            return "\(Int(9/5 * (temperature - 273) + 32)) ℉"
        }
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location  = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print ("longitude = \(location.coordinate.longitude), latitude= \(location.coordinate.latitude)")
            
            let lattitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String: String] = ["lat" : lattitude, "lon" : longitude, "appid" : APP_ID ]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
        
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable!"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let parms : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: parms)
    }
    
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
            
        }
    }
    
    
    
    
}


