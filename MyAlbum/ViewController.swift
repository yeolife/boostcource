//
//  ViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/11.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - 클래스 변수

    private var allAlbums = [PHFetchResult<PHAssetCollection>]()
    let cellIdentifier_album: String = "cell"
    @IBOutlet weak var collectionView_album: UICollectionView!
    
    // 앨범의 순번
    var albumType: Int = 0 // row
    var albumCnt: Int = 0 // col
    var prefixSum: [Int] = [0, ] // 다음 뷰로 넘길 셀의 위치(indexPath.item)를 반환
    

    // MARK: - UI
    
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
    
    
    // MARK: - 함수
    
    func upperBounds(target: Int) -> Int {
        var lo: Int = 0
        var hi: Int = prefixSum.count
        
        var mid: Int
        
        while(lo + 1 < hi) {
            mid = (lo + hi) / 2
            
            if(prefixSum[mid] <= target) {
                lo = mid
            }
            else {
                hi = mid
            }
        }
        
        return hi
    }
    
    /* 2차원 앨범 셀의 row 찾기 */
    // 누적합 배열에서 현재 순번의 upperBound를 찾으면 됨
    // 찾은 후에 누적합 배열은 1번 인덱스부터 시작하므로 -1
    func albumRow(index: Int) -> Int {
        let row: Int = upperBounds(target: index) - 1
        
        return row
    }
    
    /* 2차원 앨범 셀의 col 찾기 */
    // 현재 1차원 순번에 이전 원소들의 합을 빼면 2차원 col을 알 수 있음
    // col = 현재 셀 순번 - 이전 원소 누적합
    func albumCol(index: Int, row: Int) -> Int {
        let col: Int = index - prefixSum[row]
        
        return col
    }
    
    
    // MARK: - 앨범 및 권한
    
    // 앨범 종류
    func requestCollection() {
        // 스마트 앨범 (최근, 좋아요)
        let albumTypes: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites]
        
        for i in 0..<albumTypes.count {
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: albumTypes[i], options: nil)
            allAlbums.append(smartAlbum)
        }
        
        // 유저의 모든 앨범
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
    
    // 셀 크기 (기준: 아이폰se의 width)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = (photoInfo.shared.screenWidth - 30) / 172
        let widthPadding = 10 * (itemsPerRow + 1)
        let cellWidth = (photoInfo.shared.screenWidth - widthPadding) / itemsPerRow
                        
        return CGSize(width: cellWidth, height: cellWidth + 40)
    }
    
    // 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        for i in 1...allAlbums.count {
            prefixSum.append(prefixSum[i-1] + allAlbums[i-1].count)
        }
        
        return prefixSum[allAlbums.count]
    }
    
    // 셀 내용
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
        
        let allAlbum = allAlbums[albumType][albumCnt] // albumType -> [0] = 최근, [1] = 좋아요, [2] 유저의 모든 앨범
        let photoInAlbums = PHAsset.fetchAssets(in: allAlbum, options: sortDate)
        var resultFirstPhoto:UIImage = UIImage()
        
        // 1. 하나의 앨범에 대해서 정보를 불러옴
        if(photoInAlbums.firstObject != nil) {
            guard let firstPhoto = photoInAlbums.firstObject else {
                return cell
            }
            photoInfo.shared.options.isSynchronous = true
            photoInfo.shared.imageManager.requestImage(for: firstPhoto,
                                      targetSize: PHImageManagerMaximumSize,
                                      contentMode: .aspectFill,
                                      options: photoInfo.shared.options)
            { (image, info) in resultFirstPhoto = image! } // 앨범 이미지
        }
        
//        // 2. 각각의 모든 앨범에 대해서 정보를 불러옴 (1번과 결과는 같으나 지금 상황에서는 비효율적)
//        allAlbums[albumType].enumerateObjects {(collection, index, object) in
//            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
//            cell.label_albumCount.text = "\(photoInAlbum.count)"
//        }
        
        cell.updateText(title: allAlbum.localizedTitle!, count: photoInAlbums.count)
        cell.updateImage(image: resultFirstPhoto)
        
        albumCnt += 1
        
        if(allAlbums[albumType].count <= albumCnt) {
            albumType += 1
            albumCnt = 0
        }
                
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let nextViewController: photoViewController = segue.destination as? photoViewController else {
            return
        }
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else {
            return
        }
        
        guard let index: IndexPath = self.collectionView_album.indexPath(for: cell) else {
            return
        }
        
        let albumRow = albumRow(index: index.item)
        let albumCol = albumCol(index: index.item, row: albumRow)
        
        nextViewController.albumIndex = index.item
        nextViewController.albumInCollection = allAlbums[albumRow][albumCol]
        nextViewController.albumInTitle = allAlbums[albumRow][albumCol].localizedTitle ?? "" // 앨범 제목
    }
}

