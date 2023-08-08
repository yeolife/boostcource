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
        cell.image_city.image = UIImage(named: cityWeather(state: cities.state))
        cell.name_city.text = cities.city_name
        cell.temperature_city.text = cities.celsiusAndFahrenheit
        cell.rainfall_probability_city.text = cities.rainfall
        
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
