//
//  albumCollectionViewCell.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit

class albumCollectionViewCell: UICollectionViewCell {
    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var albumTitleLabel: UILabel!
    @IBOutlet var albumCountLabel: UILabel!
    
    func updateImage(image: UIImage) {
        self.albumImageView.image = image
    }
    
    func updateTitle(title: String) {
        self.albumTitleLabel.text = title
        
    }
    
    func updateCount(count: Int) {
        self.albumCountLabel.text = "\(count)"
    }
}
