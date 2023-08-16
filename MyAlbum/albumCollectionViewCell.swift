//
//  albumCollectionViewCell.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit

class albumCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView_album: UIImageView!
    @IBOutlet var label_albumName: UILabel!
    @IBOutlet var label_albumCount: UILabel!
    
    func updateText(title: String, count: Int) {
        self.label_albumName.text = title
        self.label_albumCount.text = "\(count)"
    }
    
    func updateImage(image: UIImage) {
        self.imageView_album.image = image
    }
}
