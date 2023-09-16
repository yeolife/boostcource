//
//  TableViewCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/01.
//

import UIKit

class listTableViewCell: UITableViewCell {
    @IBOutlet var moviePoster: UIImageView?
    @IBOutlet var movieAge: UIImageView?
    @IBOutlet var movieTitle: UILabel?
    @IBOutlet var movieGrade: UILabel?
    @IBOutlet var movieReleaseDate: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionStyle = .none

        // Configure the view for the selected state
    }

}
