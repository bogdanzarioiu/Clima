

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
    
}


struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=28ff23ca85384c074202ea8bccf807dc"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitide: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "\(weatherURL)&lat=\(latitide)&lon=\(longitude)"
        performRequest(with: url)
        
    }
    
    
    func performRequest(with urlString: String) {
        //create a URL
        guard let url = URL(string: urlString) else { return }
        
        //create a URL session
        let session = URLSession(configuration: .default)
        //give the session a task
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
            }
            guard let data = data else { return }
            if let weather = self.parseJSON(data) {
                self.delegate?.didUpdateWeather(self, weather: weather)
                
            }
            
        
        }
            task.resume()
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print(weather.temperatureString)
            return weather
            
            
        } catch {
            delegate?.didFailWithError(error: error)
        }
        return nil
    }
    
    

}





