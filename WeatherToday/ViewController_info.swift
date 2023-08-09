//
//  ViewController_info.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/08.
//

import UIKit

class ViewController_info: UIViewController {
    
    var get_state_currentCity: Int!
    var get_temperature_currentCity: String!
    var get_rainfall_probability_currentCity_string: String!
    var get_rainfall_probability_currentCity_int: Int!
    
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var image_currentCity: UIImageView!
    @IBOutlet weak var state_currentCity: UILabel!
    @IBOutlet weak var temperature_currentCity: UILabel!
    @IBOutlet weak var rainfall_currentCity: UILabel!
    
    
    
    // MARK: - viewDidLoad
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(get_rainfall_probability_currentCity_int >= 50 && get_rainfall_probability_currentCity_int < 80) {
            rainfall_currentCity.textColor = .orange
        }
        else if(get_rainfall_probability_currentCity_int >= 80) {
            rainfall_currentCity.textColor = .red
        }
        else {
            rainfall_currentCity.textColor = .blue
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.image_currentCity.image = UIImage(named: cityWeather_english(state: get_state_currentCity))
        self.state_currentCity.text = cityWeather_korean(state: get_state_currentCity)
        self.temperature_currentCity.text = get_temperature_currentCity
        self.rainfall_currentCity.text = get_rainfall_probability_currentCity_string
    }
                                               
   func cityWeather_english(state: Int) -> String {
       if(state == 10) {
           return "sunny"
       }
       else if(state == 11) {
           return "cloudy"
       }
       else if(state == 12) {
           return "rainy"
       }
       else if(state == 13) {
           return "snowy"
       }
       
       return "sunny"
   }
    
    func cityWeather_korean(state: Int) -> String {
        if(state == 10) {
            return "맑음"
        }
        else if(state == 11) {
            return "구름 많음"
        }
        else if(state == 12) {
            return "비"
        }
        else if(state == 13) {
            return "눈"
        }
        
        return "error"
    }
}
