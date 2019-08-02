import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "532ccffe0aff60977e5d1cbe0c307c1c"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - AlamoNetworking

    //Getting data from API
    func getWeatherData(url: String, parameters:[String:String]){
        
        Alamofire.request(url, method: .get, parameters:parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got the data")
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
                
            }
            else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
                
            }
            
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    
    func updateWeatherData (json:JSON){
        
        if let tempResult = json["main"]["temp"].double{
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weathericonName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather unavaliable"
        }
    }

    
    
    
    //MARK: - UI Updates
    //Updaiting Data according data from API
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weathericonName)
    }
    
    
    
    
    
    //MARK: - Location Manager Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            print ("longtitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longtitude = String(location.coordinate.longitude)
            let params: [String:String] = ["lat":latitude,"lon":longtitude, "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
            locationManager.delegate = nil
    }
        
        
    }
    
    
    //Location Error Handler
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    //Catching city name out of user input
    func userEnteredANewCityName(city: String) {
        let params : [String:String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //prep for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self 
        }
    }
    
    
    
    
}


