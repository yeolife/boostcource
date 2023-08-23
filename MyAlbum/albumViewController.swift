//
//  ViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/11.
//

import UIKit
import Photos

class albumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, reloadDelegate {
    
    private var allAlbums = [PHFetchResult<PHAssetCollection>]()
    
    @IBOutlet weak var collectionView_album: UICollectionView!
    
    let cellIdentifier_album: String = "cell"
    
    
    // -----------------------------------------
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.collectionView_album.delegate = self
        
        setupLayout()
        
        checkAuthorization()
        
        setupAlbums()
        
        setupAlbumIndexArray()
        
        setupDataSource()
        
        setupSnapshot()
    }
    
    
    func setupLayout() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        
        self.collectionView_album.collectionViewLayout = flowLayout
    }
    
    
    // -----------------------------------------
    // MARK: - 앨범의 전처리 및 권한 재확인
    
    
    // 1. 권한 확인
    func checkAuthorization() {
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
    
    
    // 1-1. 접근권한 거부상태일 때 띄우는 알림창
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
    
    
    // 2. 앨범 종류 선정
    func requestCollection() {
        let smartAlbumType: [PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumFavorites] // 스마트 앨범 (최근, 좋아요)
        
        for i in 0..<smartAlbumType.count {
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: smartAlbumType[i], options: nil)
            allAlbums.append(smartAlbum)
        }
        
        allAlbums.append(PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)) // 유저의 모든 앨범
    }
    
    
    // 3. 선정한 앨범 컬렉션의 정보를 전처리
    func setupAlbums() {
        // 1. PHFetchResult<PHAssetCollection> in [PHFetchResult<PHAssetCollection>]
        for allAlbum in allAlbums {
            
            // 2. PHAssetCollection in PHFetchResult<PHAssetCollection>
            allAlbum.enumerateObjects { album, _, _ in
                
                photoInfo.shared.sortDate(state: false)
                
                // 3. PHFetchResult<PHAsset> in PHAssetCollection
                let collectionInAlbum = PHAsset.fetchAssets(in: album, options: photoInfo.shared.sortOption)

                // 4. PHAsset in PHFetchResult<PHAsset>
                let firstPhoto = collectionInAlbum.firstObject ?? PHAsset()
                
                self.albumsInfo.append(Item(albumTitle: album.localizedTitle ?? "",
                                            thumbnailAsset: firstPhoto,
                                            photoCount: collectionInAlbum.count))
            }
        }
    }
    
    
    // -----------------------------------------
    // MARK: - PHFetchResult 안에서 앨범의 순번을 찾기 위한 함수들
    
    var albumType: Int = 0 // row
    var albumCnt: Int = 0 // col
    var prefixSum: [Int] = [0, ] // 다음 뷰로 넘길 셀의 위치(indexPath.item)를 반환
    
    
    func setupAlbumIndexArray() {
        for i in 1...allAlbums.count {
            prefixSum.append(prefixSum[i-1] + allAlbums[i-1].count)
        }
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

    
    // -----------------------------------------
    // MARK: - 컬렉션 뷰
    
    var albumsInfo: [Item] = []
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    
    enum Section: CaseIterable {
        case album
    }
    
    
    class Item: Hashable {
        var uuid: UUID = UUID()
        var albumTitle: String = ""
        var thumbnailAsset: PHAsset = PHAsset()
        var firstPhotoImage = UIImage()
        var photoCount: Int = 0
        
        init(albumTitle: String, thumbnailAsset: PHAsset, photoCount: Int) {
            self.albumTitle = albumTitle
            self.thumbnailAsset = thumbnailAsset
            self.firstPhotoImage = photoInfo.shared.assetToImage(asset: thumbnailAsset)
            self.photoCount = photoCount
        }
        
        static func == (lhs: albumViewController.Item, rhs: albumViewController.Item) -> Bool {
            lhs.uuid == rhs.uuid
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }
    
    
    // 셀 형태(데이터 소스)
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item> (collectionView: self.collectionView_album,
                                                                        cellProvider: {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.cellIdentifier_album,
                for: indexPath) as? albumCollectionViewCell else {
                fatalError("Unable to dequeue AlbumCollectionViewCell")
            }
            
            cell.updateImage(image: item.firstPhotoImage)
            cell.updateText(title: item.albumTitle, count: item.photoCount)
            
            return cell
        })
    }
    
    
    // 셀 내용(스냅샷)
    func setupSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.album])

        snapshot.appendItems(albumsInfo)
        
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // 셀 크기 (기준: 아이폰se의 width)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = (photoInfo.shared.screenWidth - 30) / 172
        let widthPadding = 10 * (itemsPerRow + 1)
        let cellWidth = (photoInfo.shared.screenWidth - widthPadding) / itemsPerRow
                        
        return CGSize(width: cellWidth, height: cellWidth + 40)
    }
    
    
    // -----------------------------------------
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let nextVC: photoViewController = segue.destination as? photoViewController else {
            return
        }
        
        nextVC.photoViewDelegate = self
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath: IndexPath = self.collectionView_album.indexPath(for: cell) else {
            return
        }
        
        let row = albumRow(index: indexPath.item)
        let col = albumCol(index: indexPath.item, row: row)
        
        nextVC.albumIndexPath = indexPath
        nextVC.albumTitle = allAlbums[row][col].localizedTitle ?? "" // 앨범 제목
        nextVC.collectionAlbum = allAlbums[row][col]
    }
    
    
    // 앨범 내의 사진에서 변화가 발생하는 delegate
    func reloadView(msg: String, indexPath: IndexPath) {
        // 변화가 발생한 앨범 불러옴
        let row: Int = albumRow(index: indexPath.item)
        let col: Int = albumCol(index: indexPath.item, row: row)
        let collectionInAlbum = PHAsset.fetchAssets(in: allAlbums[row][col], options: photoInfo.shared.sortOption)
        
        // refresh
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        item.thumbnailAsset = collectionInAlbum.firstObject ?? PHAsset()
        item.firstPhotoImage = photoInfo.shared.assetToImage(asset: item.thumbnailAsset)
        item.photoCount = collectionInAlbum.count

        // 단일 스냅샷
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        print(msg)
    }
}
