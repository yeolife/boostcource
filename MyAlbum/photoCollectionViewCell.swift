//
//  photoCollectionViewCell.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/19.
//

import UIKit

class photoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView_photo: UIImageView!
    
    func clickImageView(state: Bool) {
        if(state) {
            self.imageView_photo.alpha = 0.7
            self.imageView_photo.layer.borderColor = UIColor.systemBlue.cgColor
            self.imageView_photo.layer.borderWidth = 2
        }
        else {
            self.imageView_photo.alpha = 1.0
            self.imageView_photo.layer.borderColor = .none
            self.imageView_photo.layer.borderWidth = .zero
        }
    }
}
