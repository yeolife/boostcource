//
//  singlePhotoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/23.
//

import UIKit
import Photos

class singlePhotoViewController: UIViewController {
    
    var singlePhotoImage: UIImage = UIImage()
    var singlePhotoAsset: PHAsset = PHAsset()
    @IBOutlet weak var singlePhotoImageView: UIImageView!
    
    @IBOutlet weak var bottomNavigationBar: UINavigationBar!
    
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
    // MARK: - 사진 확대/축소
    
    var pinchState: Bool = false
    
    // 상태바 배경색깔
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let statusBarFrame = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame
            if let statusBarFrame = statusBarFrame {
                let statusBar = UIView(frame: statusBarFrame)
                view.addSubview(statusBar)
                return statusBar
            } else {
                return nil
            }
        } else {
            return UIApplication.shared.value(forKey: "statusBar") as? UIView
        }
    }
    
    @objc func imageViewTap(_ gesture: UITapGestureRecognizer) {
        pinchState.toggle()
        
        if(pinchState == true) {
            view.backgroundColor = .black
            statusBarView?.backgroundColor = .black
            self.navigationController?.navigationBar.backgroundColor = nil
            self.navigationItem.titleView?.isHidden = true
            self.navigationItem.hidesBackButton = true
            self.bottomNavigationBar.isHidden = true
        }
        else {
            view.backgroundColor = .white
            statusBarView?.backgroundColor = .white
            self.navigationController?.navigationBar.backgroundColor = .white
            self.navigationItem.titleView?.isHidden = false
            self.navigationItem.hidesBackButton = false
            self.bottomNavigationBar.isHidden = false
        }
    }
    
    let minScale: CGFloat = 0.3
    let maxScale: CGFloat = 4.0
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if(gesture.state == .changed && !pinchState) {
            pinchState = true
            
            view.backgroundColor = .black
            statusBarView?.backgroundColor = .black
            self.navigationController?.navigationBar.backgroundColor = nil
            self.navigationItem.titleView?.isHidden = true
            self.navigationItem.hidesBackButton = true
            self.bottomNavigationBar.isHidden = true
        }
        
        if let view = gesture.view {
            let currentScale = view.frame.size.width / view.bounds.size.width
            var newScale = currentScale * gesture.scale
            
            if newScale > maxScale {
                newScale = maxScale
            }
            
            if(newScale < minScale) {
                newScale = minScale
            }
            
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            view.transform = transform
            gesture.scale = 1
        }
    }
    
    
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

        // 네비게이션 바를 상위에 배치
        view.bringSubviewToFront(bottomNavigationBar)
        
        
        // 네비게이션 타이틀을 생성 일자 및 시각로 설정
        photoCreationDate = self.singlePhotoAsset.creationDate ?? Date()
        self.navigationItem.titleView = dateTitle()
        
        
        // 단일 사진
        singlePhotoImage = photoInfo.shared.assetToImage(asset: singlePhotoAsset)
        self.singlePhotoImageView.image = singlePhotoImage
        
        
        // 화면(이미지) 탭 했을 때 발생
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTap))
        singlePhotoImageView.addGestureRecognizer(tapGesture)
        singlePhotoImageView.isUserInteractionEnabled = true
        
        
        // 핀치 제스처로 사진 확대 및 축소
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(singlePhotoViewController.handlePinch(_:)))
        self.singlePhotoImageView.addGestureRecognizer(pinchGesture) // 핀치 제스처 등록
        self.singlePhotoImageView.isUserInteractionEnabled = true // 사용자의 터치, 프레스, 키보드 및 포커스 이벤트를 받아들이도록 설정
        
        
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
