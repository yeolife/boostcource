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
    var selectCountry: String?
    
    
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
        
        self.navigationItem.title = "세계 날씨"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = .systemBlue
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
        cell.englishName_country = countries.asset_name
        cell.image_country?.image = UIImage(named: "flag_" + cell.englishName_country)
        
        return cell
    }
    
    
    // MARK: - Segue
    
    // SecondViewController의 Label에 현재 cell 값 넣기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
        
        guard let nextViewController: ViewController_city = segue.destination as? ViewController_city else {
            return
        }
        
        guard let cell: TableViewCell_country = sender as? TableViewCell_country else {
            return
        }
        
        // prepare 과정이라서 뷰 요소는 메모리에 있지 않음, 그래서 직접 뷰 요소에 넣지 못하고 프로퍼티에 할당함
        nextViewController.currentCountry = cell.englishName_country
        nextViewController.currentCountryKorean = cell.name_country.text
    }
}
