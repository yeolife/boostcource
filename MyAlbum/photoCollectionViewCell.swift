//
//  photoCollectionViewCell.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/19.
//

import UIKit

class photoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView_photo: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if(!isSelected) {
            layer.opacity = 1.0
            layer.borderWidth = .zero
            layer.borderColor = nil
        }
        else {
            layer.opacity = 0.7
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
}
