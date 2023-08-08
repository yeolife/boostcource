//
//  ViewController.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/07.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView_country: UITableView!
    let countryCellIdentify: String = "countryCell"
    var countries: [country] = []
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView_country.delegate = self
        self.tableView_country.dataSource = self
        
        let jsonDecoder: JSONDecoder = JSONDecoder()
        guard let dataAsset: NSDataAsset = NSDataAsset(name: "countries") else {
            return
        }
        
        do {
            self.countries = try jsonDecoder.decode([country].self, from: dataAsset.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - 테이블 뷰
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TableViewCell_country = tableView.dequeueReusableCell(withIdentifier: countryCellIdentify, for: indexPath) as? TableViewCell_country else {
            preconditionFailure("테이블 뷰 셀 가져오기 실패")
        }
        let countries: country = self.countries[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        cell.name_country?.text = countries.korean_name
        cell.image_country?.image = UIImage(named: "flag_" + countries.asset_name)
        
        return cell
    }
}
