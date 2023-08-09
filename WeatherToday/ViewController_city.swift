//
//  ViewController_city.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/08.
//

import UIKit

class ViewController_city: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView_city: UITableView!
    var currentCountry: String!
    var currentCountryKorean: String!
    let cityCellIdentify: String = "cityCell"
    var cities: [city] = []

    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView_city.delegate = self
        self.tableView_city.dataSource = self
        
        let jsonDecoder: JSONDecoder = JSONDecoder()
        guard let dataAsset: NSDataAsset = NSDataAsset(name: currentCountry) else {
            return
        }
        
        do {
            self.cities = try jsonDecoder.decode([city].self, from: dataAsset.data)
        } catch {
            print(error.localizedDescription)
        }
        
        self.navigationItem.title = currentCountryKorean
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let nextViewController: ViewController_info = segue.destination as? ViewController_info else {
            return
        }
        
        guard let cell: TableViewCell_city = sender as? TableViewCell_city else {
            return
        }
        
        nextViewController.get_state_currentCity = cell.state_city
        nextViewController.get_temperature_currentCity = cell.temperature_city.text
        nextViewController.get_rainfall_probability_currentCity_string = cell.rainfall_city.text
        nextViewController.get_rainfall_probability_currentCity_int = cell.rainfall_probability_city
    }
    
    
    // MARK: - 테이블 뷰
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TableViewCell_city = tableView.dequeueReusableCell(withIdentifier: cityCellIdentify, for: indexPath) as? TableViewCell_city else {
            preconditionFailure("테이블 뷰 셀 가져오기 실패")
        }
        let cities: city = self.cities[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        cell.state_city = cities.state
        cell.image_city.image = UIImage(named: cityWeather(state: cities.state))
        cell.name_city.text = cities.city_name
        cell.temperature_city.text = cities.celsiusAndFahrenheit
        cell.rainfall_probability_city = cities.rainfall_probability
        cell.rainfall_city.text = cities.rainfall_probability_string
        
        return cell
    }
    
    
    // MARK: - Function
    
    func cityWeather(state: Int) -> String {
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
}
