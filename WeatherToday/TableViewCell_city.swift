//
//  TableViewCell_city.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/08.
//

import UIKit

class TableViewCell_city: UITableViewCell {
    
    @IBOutlet weak var image_city: UIImageView!
    var state_city: Int!
    @IBOutlet weak var name_city: UILabel!
    @IBOutlet weak var temperature_city: UILabel!
    @IBOutlet weak var rainfall_city: UILabel!
    var rainfall_probability_city: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
