//
//  photoCollectionViewCell.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/19.
//

import UIKit

class photoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
    
    func clickImageView(state: Bool) {
        if(state) {
            self.photoImageView.layer.opacity = 0.7
            self.photoImageView.layer.borderColor = UIColor.systemBlue.cgColor
            self.photoImageView.layer.borderWidth = 2
        }
        else {
            self.photoImageView.layer.opacity = 1.0
            self.photoImageView.layer.borderColor = .none
            self.photoImageView.layer.borderWidth = .zero
        }
    }
}
