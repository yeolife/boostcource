//
//  CollectionViewCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/01.
//

import UIKit

class listCollectionViewCell: UICollectionViewCell {
    @IBOutlet var moviePoster: UIImageView?
    @IBOutlet var movieAge: UIImageView?
    @IBOutlet var movieTitle: UILabel?
    @IBOutlet var movieGrade: UILabel?
    @IBOutlet var movieReleaseDate: UILabel?
}
