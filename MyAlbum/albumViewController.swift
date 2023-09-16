//
//  ViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/11.
//

import UIKit
import Photos

class albumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
 
    private var albumCollection = [PHFetchResult<PHAssetCollection>]()
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    let albumCellIdentifier: String = "cell"
    
    
    // -----------------------------------------
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.albumCollectionView.delegate = self
        
        setupLayout()
        
        checkAuthorization()
                        
        setupDataSource()
        
        setupSnapshot()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    
    func setupLayout() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        
        self.albumCollectionView.collectionViewLayout = flowLayout
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
                        self.albumCollectionView.reloadData()
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
            albumCollection.append(smartAlbum)
        }
        
        let userAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        albumCollection.append(userAlbum) // 유저의 모든 앨범
    }
    
    
    // 3. 선정한 앨범 컬렉션의 정보를 전처리
    func setupAlbums() -> [Item] {
        var albumItem: [Item] = []
        
        // PHFetchResult<PHAssetCollection> in [PHFetchResult<PHAssetCollection>]
        for collection in albumCollection {
            
            // PHAssetCollection in PHFetchResult<PHAssetCollection>
            collection.enumerateObjects { album, _, _ in
                albumItem.append(Item(albumCollection: album))
            }
        }
        
        return albumItem
    }
    
    
    // -----------------------------------------
    // MARK: - 앨범 변화 감지 옵저버
    
    
    // 실제 사진첩에서 앨범의 개수가 변화하면 발생
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 모든 앨범 스냅샷
        var snapshot = dataSource.snapshot()
        
        let fetch = snapshot.itemIdentifiers(inSection: .album)
        
        for fetchResult in fetch {
            fetchResult.thumbnailInfo()
        }
        
        snapshot.reloadItems(fetch)
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
        
        
        // 단일 앨범 스냅샷
//        let snapshot = dataSource.snapshot()
//
//        let items = snapshot.itemIdentifiers(inSection: .album)
//
//        if let item = items.first(where: { $0.uuid == uuid }) {
//            item.thumbnailInfo()
//
//            var snapshot = dataSource.snapshot()
//            snapshot.reloadItems([item])
//            dataSource.apply(snapshot, animatingDifferences: false)
//        }
    }

    
    // -----------------------------------------
    // MARK: - 컬렉션 뷰
    
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    
    enum Section: CaseIterable {
        case album
    }
    
    
    class Item: Hashable {
        var uuid: UUID = UUID()
        
        var albumCollection: PHAssetCollection = PHAssetCollection()
        
        var firstPhotoImage = UIImage()
        var albumTitle: String = ""
        var albumCount: Int = 0

        init(albumCollection: PHAssetCollection) {
            self.albumCollection = albumCollection
            self.albumTitle = self.albumCollection.localizedTitle ?? ""
            self.thumbnailInfo()
        }
        
        static func == (lhs: albumViewController.Item, rhs: albumViewController.Item) -> Bool {
            lhs.uuid == rhs.uuid
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
        
        func thumbnailInfo() {
            photoInfo.shared.sortDate(state: false)
            
            // PHFetchResult<PHAsset> in PHCollection
            let assetInCollection = PHAsset.fetchAssets(in: self.albumCollection,
                                                        options: photoInfo.shared.sortOption)
            
            // PHAsset in PHFetchResult<PHAsset>
            let firstAsset = assetInCollection.firstObject ?? PHAsset()
            
            self.firstPhotoImage = photoInfo.shared.assetToImage(asset: firstAsset)
            self.albumCount = assetInCollection.count
        }
    }
    
    
    // 셀 형태(데이터 소스)
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item> (collectionView: self.albumCollectionView,
                                                                        cellProvider: {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.albumCellIdentifier,
                for: indexPath) as? albumCollectionViewCell else {
                fatalError("Unable to dequeue AlbumCollectionViewCell")
            }
            
            cell.updateImage(image: item.firstPhotoImage)
            cell.updateTitle(title: item.albumTitle)
            cell.updateCount(count: item.albumCount)
            
            return cell
        })
    }
    
    
    // 셀 내용(스냅샷)
    func setupSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.album])

        snapshot.appendItems(setupAlbums())
        
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
                
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath: IndexPath = self.albumCollectionView.indexPath(for: cell) else {
            return
        }
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        nextVC.albumCollection = item.albumCollection
    }
}
