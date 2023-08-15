//
//  ViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/11.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - 변수
    
    var albumType: Int = 0
    var albumCnt: Int = 0
    private var allAlbums = [PHFetchResult<PHAssetCollection>]()
    let cellIdentifier_album: String = "cell"
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    var options = PHImageRequestOptions()
    let screenWidth: CGFloat = { // 절대적인 화면 너비값
        let screenSize = UIScreen.main.bounds.size
        let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let interfaceOrientation = windowScene.interfaceOrientation

        if interfaceOrientation.isPortrait {
            return screenSize.width
        }
        else {
            return screenSize.height
        }
    }()
    
    
    // MARK: - IB
    
    @IBOutlet weak var collectionView_album: UICollectionView!
    
    
    // MARK: - 사진
    
    func requestCollection() {
        // 스마트 앨범 (최근, 좋아요)
        let albumTypes: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites]
        for i in 0..<albumTypes.count {
            allAlbums.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: albumTypes[i], options: nil))
        }
        
        // 유저 앨범
        allAlbums.append(PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil))
    }
    
    
    // 접근권한 거부상태일 때 띄우는 알림창
    func showAlertAuth(_ type: String) {
        if let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String {
            
           let alertVC = UIAlertController(
               title: "설정",
               message: "\(appName) 이(가) '\(type)' 접근이 허용되어 있지 않습니다. 설정화면으로 가시겠습니까?",
               preferredStyle: .alert
           )
            
           let cancelAction = UIAlertAction(
               title: "취소",
               style: .cancel,
               handler: nil
           )
            
           let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
               UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
           }
            
           alertVC.addAction(cancelAction)
           alertVC.addAction(confirmAction)
            
           self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - 컬렉션 뷰
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var sum: Int = 0
        
        for allAlbum in allAlbums {
            sum += allAlbum.count
        }
        
        return sum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: self.cellIdentifier_album,
            for: indexPath) as? albumCollectionViewCell else {
            fatalError("Unable to dequeue AlbumCollectionViewCell")
        }
        
        // 정렬
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // 날짜 내림차순
//        let sortTitle = PHFetchOptions()
//        sortTitle.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)] // 제목 내림차순
        
        // albumType. [0] = 최근, [1] = 좋아요, [2] 유저의 모든 앨범
        let allAlbum = allAlbums[albumType][albumCnt]
                        
        let photoInAlbums = PHAsset.fetchAssets(in: allAlbum, options: sortDate)
        
        // 1. 하나의 앨범에 대해서 정보를 불러옴
        let firstPhoto = photoInAlbums.firstObject
        var resultFirstPhoto: UIImage!
        options.isSynchronous = true
        imageManager.requestImage(for: firstPhoto!,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFill,
                                  options: options)
        { (image, info) in resultFirstPhoto = image } // 앨범 이미지
        
//        // 2. 각각의 모든 앨범에 대해서 정보를 불러옴 (1번과 결과는 같으나 지금 상황에서는 비효율적)
//        allAlbums[albumType].enumerateObjects {(collection, index, object) in
//            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
//            cell.label_albumCount.text = "\(photoInAlbum.count)"
//        }
        
        cell.update(title: allAlbum.localizedTitle!, count: photoInAlbums.count, image: resultFirstPhoto)
        
        albumCnt += 1
        
        if(allAlbums[albumType].count <= albumCnt) {
            albumType += 1
            albumCnt = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 해상도에 따른 행의 수 (기준: 아이폰se의 width)
        let itemsPerRow: CGFloat = (screenWidth - 30) / 172
        let widthPadding = 10 * (itemsPerRow + 1)
        let cellWidth = (screenWidth - widthPadding) / itemsPerRow
                        
        return CGSize(width: cellWidth, height: cellWidth + 40)
    }
    
    
    // MARK: - 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_album.delegate = self
        self.collectionView_album.dataSource = self
        
        // flowLayout
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        self.collectionView_album.collectionViewLayout = flowLayout
        
        // 갤러리 접근 권한
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가된 상태")
            self.requestCollection()
        case .denied:
            print("접근 불허된 상태")
            self.showAlertAuth("앨범") // 설정창으로 이동하라는 Alert
        case .notDetermined:
            print("아직 응답하지 않은 상태")
            PHPhotoLibrary.requestAuthorization({ status in
                switch status {
                case .authorized:
                    print("사용자가 접근을 허용함")
                    self.requestCollection()
                    
                    OperationQueue.main.addOperation { // reload는 메인 스레드에서만 동작
                        self.collectionView_album.reloadData()
                    }
                    
                case .denied:
                    print("사용자가 접근을 불허함")
                default:
                    break
                }
            })
        case .restricted:
            print("접근 제한")
        default: break
        }
    }
}

