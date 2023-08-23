//
//  singlePhotoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/23.
//

import UIKit
import Photos

class singlePhotoViewController: UIViewController {

    
    //    사진 확대/축소 기능
    //    사진을 핀치 제스쳐를 사용하여 확대/축소할 수 있습니다.
    //    사진을 터치하거나 확대/축소하면 툴바와 내비게이션바가 사라집니다.
    //    다시 사진을 터치하면 툴바와 내비게이션바가 나타납니다.
    
    
    var singlePhotoImage: UIImage = UIImage()
    var singlePhotoAsset: PHAsset = PHAsset()
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photoCreationDate: Date = Date()
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "a HH:mm:ss"
        
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
    
    // -----------------------------------------
    // MARK: - 선택 사진 공유

    @IBOutlet weak var shareButton: UIBarButtonItem!

    @IBAction func touchUpShareButton(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [singlePhotoImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, success, returnedItems, error) in
            if(success) {
                print("단일 사진 공유 성공")
            }
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // -----------------------------------------
    // MARK: - 선택 사진 삭제
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!

    @IBAction func touchUpDeleteButton(_ sender: UIBarButtonItem) {
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets([self.singlePhotoAsset] as NSFastEnumeration)},
                                               completionHandler: { (success, error) in
                                                if (success) {
                                                    DispatchQueue.main.async {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }})
    }


    // -----------------------------------------
    // MARK: - 선택 사진 좋아요
    
    var isFavoriteState: Bool = false
    
    @IBOutlet weak var favoriteButton: UIButton!

    @IBAction func touchUpFavoriteButton(_ sender: UIButton) {
        
        isFavoriteState.toggle()
        
        self.favoriteButton.setTitle(self.isFavoriteState ? "❤️" : "🤍", for: .normal)
        
        PHPhotoLibrary.shared().performChanges( { let changeRequest = PHAssetChangeRequest(for: self.singlePhotoAsset)
            changeRequest.isFavorite = self.isFavoriteState },
                                                completionHandler: { success, error in
            if(success) {
                print("좋아요 토글 성공")
            }
            else {
                print("좋아요 토글 실패")
            }
        })
    }
    
    
    //-----------------------------
    // MARK: UI
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 네비게이션 아이템의 타이틀은 이전 화면에서 선택된 사진 생성 일자 및 시각입니다.
        photoCreationDate = self.singlePhotoAsset.creationDate ?? Date()
        self.navigationItem.titleView = dateTitle()
        
        
        // 단일 사진
        singlePhotoImage = photoInfo.shared.assetToImage(asset: singlePhotoAsset)
        self.imageView.image = singlePhotoImage
        
        
        // 좋아요 상태
        self.isFavoriteState = self.singlePhotoAsset.isFavorite
        self.favoriteButton.setTitle(self.isFavoriteState ? "❤️" : "🤍", for: .normal)
    }
    
    
    func dateTitle() -> UIStackView {
        let dateLabel = UILabel()
        
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        dateLabel.text = dateFormatter.string(from: photoCreationDate)
        
        let timeLabel = UILabel()
        
        timeLabel.textColor = .gray
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        timeLabel.text = timeFormatter.string(from: photoCreationDate)
        
        let dateStackView = UIStackView(arrangedSubviews: [dateLabel, timeLabel])
        dateStackView.axis = .vertical
        
        return dateStackView
    }
}
