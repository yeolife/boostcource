//
//  TableViewCell_country.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/08.
//

import UIKit

class TableViewCell_country: UITableViewCell {
    
    @IBOutlet weak var image_country: UIImageView!
    @IBOutlet weak var name_country: UILabel!
    var englishName_country: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
