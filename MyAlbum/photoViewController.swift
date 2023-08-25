//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos

class photoViewController: UIViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    

    // -----------------------------------------
    // MARK: - 클래스 변수
        
    var albumTitle: String = String()
    
    var albumInPhoto: [Item] = []
    var albumInAsset : PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    var albumCollection: PHAssetCollection!
    
    let photoCellIdentifier: String = "cell"
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    // -----------------------------------------
    // MARK: - 사진 정렬
    
    var sortStatus: Bool = false
    
    @IBOutlet weak var sortButton: UIButton!
    
    @IBAction func touchUpSortButton(_ sender: UIButton) {
        if(!sortStatus) {
            sortButton.setTitle("과거순", for: .normal)
        }
        else {
            sortButton.setTitle("최신순", for: .normal)
        }
        
        sortStatus.toggle()
        
        var snapshot = dataSource.snapshot()
        
        var items = snapshot.itemIdentifiers(inSection: .album)
        items.reverse()
        
        snapshot.deleteItems(items)
        snapshot.appendItems(items)
                
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
 
    
    // -----------------------------------------
    // MARK: - 사진 선택
    
    var multiSelectStatus: Bool = false
    var selectPhotos: Set<Item> = []
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    @IBAction func touchUpSelectButton(_ sender: UIBarButtonItem) {
        multiSelectStatus.toggle()
        sortButton.isEnabled.toggle()
        
        switch multiSelectStatus {
        case true:
            self.navigationItem.title = "항목 선택"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        case false:
            self.ItemInit(state: "cancle")
                        
            self.navigationItem.title = albumTitle
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
    }
    
    
    // -----------------------------------------
    // MARK: - 선택 사진 공유
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    
    
    @IBAction func touchUpShareButton(_ sender: UIBarButtonItem) {
        var sharePhotos = [UIImage]()
        
        sharePhotos = selectPhotos.map { photoInfo.shared.assetToImage(asset: $0.photoAsset) }
        
        let activityViewController = UIActivityViewController(activityItems: sharePhotos, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, success, returnedItems, error) in
            if(success && activityType == UIActivity.ActivityType.saveToCameraRoll) {
                self.ItemInit(state: "share")
            }
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // -----------------------------------------
    // MARK: - 선택 사진 삭제
    
    @IBOutlet weak var deleteButton: UIBarButtonItem! {
        didSet {
            deleteButton.isEnabled = false
        }
    }
    
    
    @IBAction func touchUpDeleteButton(_ sender: UIBarButtonItem) {
        var deleteAssets = [PHAsset]()
                
        deleteAssets = selectPhotos.map { $0.photoAsset }
        
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(deleteAssets as NSFastEnumeration)},
                                               completionHandler: { (success, error) in
                                                if (success) {
                                                    OperationQueue.main.addOperation {
                                                        self.ItemInit(state: "delete")
                                                        
                                                    }
                                                    
                                                }
                                                else {
                                                    print("삭제 취소 또는 오류 발생")
                                                }})
    }
    
    
    // -----------------------------------------
    // MARK: - 사진들 상태 변화 적용
        

    func ItemInit(state: String) {
        shareButton.isEnabled = false // 공유 비활성화
        deleteButton.isEnabled = false // 삭제 비활성화
        sortButton.isEnabled = true
        
        var itemList: [Item] = [Item]()
        
        itemList = selectPhotos.map { item in
            item.onSelected = false
            
            return item
        }
        
        var snapshot = dataSource.snapshot()
        
        switch state {
        case "cancle":
            snapshot.reloadItems(itemList)
        case "share", "delete":
            switch state {
            case "share":
                snapshot.appendItems(itemList)
            case "delete":
                snapshot.deleteItems(itemList)
            default:
                return
            }
            self.navigationItem.title = "항목 선택"
        default:
            return
        }
        
        dataSource.apply(snapshot)
                
        selectPhotos.removeAll()
    }
 
    
    // -----------------------------------------
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoCollectionView.delegate = self
        
        setupNavigationBar()
        
        setupLayout()
        
        setupPhotos(state: false)
        
        setupDataSource()
        
        setupSnapshot()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    
    func setupNavigationBar() {
        self.albumTitle = albumCollection.localizedTitle ?? ""
        self.navigationItem.title = albumTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
    }
    
    
    func setupLayout() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        
        self.photoCollectionView.collectionViewLayout = flowLayout
    }
    
    
    // -----------------------------------------
    // MARK: - 사진 전처리 및 옵저버
    
    
    func setupPhotos(state: Bool) { // 사진들 전처리
        photoInfo.shared.sortDate(state: state)
        
        albumInAsset = PHAsset.fetchAssets(in: albumCollection, options: photoInfo.shared.sortOption)
        
        albumInPhoto = albumInAsset.objects(at: IndexSet(integersIn: 0..<albumInAsset.count)).map { Item(asset: $0) }
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let changes = changeInstance.changeDetails(for: albumInAsset) {
            albumInAsset = changes.fetchResultAfterChanges
            
            albumInPhoto = albumInAsset.objects(at: IndexSet(integersIn: 0..<albumInAsset.count)).map { Item(asset: $0) }

            setupSnapshot()
        }
    }
    
    
    // -----------------------------------------
    // MARK: - 컬렉션 뷰
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    
    enum Section: CaseIterable {
        case album
    }
    
    
    class Item: Hashable {
        var uuid: UUID = UUID()
        var photoAsset: PHAsset
        var photoImage = UIImage()
        var onSelected: Bool = false
        init(asset: PHAsset) {
            self.photoAsset = asset
            self.photoImage = photoInfo.shared.assetToImage(asset: self.photoAsset)
        }
        
        static func == (lhs: photoViewController.Item, rhs: photoViewController.Item) -> Bool {
            lhs.uuid == rhs.uuid
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }
    
    
    // 셀 형태 (데이터 소스)
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.photoCollectionView,
                                                                            cellProvider: {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.photoCellIdentifier,
                for: indexPath) as? photoCollectionViewCell else {
                fatalError("Unable to dequeue AlbumCollectionViewCell")
            }
            
            cell.photoImageView.image = item.photoImage
            cell.clickImageView(state: item.onSelected)
            
            return cell
        })
    }
    
    
    // 셀 내용 (스냅샷)
    func setupSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.album])
        
        snapshot.appendItems(albumInPhoto)
                
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // 셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2 * (3 - 1)
        let cellWidth = (photoInfo.shared.screenWidth - itemsPerRow) / 3
                
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    // 셀 선택 딜리게이트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 사진 선택 중...
        if(multiSelectStatus) {
            // 선택된 셀의 상태를 변경하고 스냅샷에 전달
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            item.onSelected.toggle()

            // 단일 스냅샷
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([item])
            dataSource.apply(snapshot, animatingDifferences: false)
            
            
            // 선택한 셀들을 배열에 저장하고, 선택을 해제하면 삭제
            if(item.onSelected == true) {
                selectPhotos.insert(item)
            }
            else {
                selectPhotos.remove(item)
            }
            
            
            // 현재 선택한 셀의 수에 따라 버튼 활성화
            if(selectPhotos.count == 1) {
                shareButton.isEnabled = true // 공유 버튼 활성화
                deleteButton.isEnabled = true // 삭제 버튼 활성화
            }
            else if(selectPhotos.count == 0) {
                shareButton.isEnabled = false
                deleteButton.isEnabled = false
            }
            
            
            // 선택한 셀의 개수를 제목에 표시
            switch selectPhotos.count {
            case 0:
                navigationItem.title = "항목 선택"
            case 1...:
                navigationItem.title = "\(selectPhotos.count)장 선택"
            default:
                return
            }
        }
    }
    
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let nextVC: singlePhotoViewController = segue.destination as? singlePhotoViewController else {
            return
        }
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath: IndexPath = self.photoCollectionView.indexPath(for: cell) else {
            return
        }
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        nextVC.singlePhotoAsset = item.photoAsset
    }
    
    
    // 다중 선택 상태에 따라 segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == "singlePhotoSegue") {
            if(multiSelectStatus) {
                return false
            } else {
                return true
            }
        }
        else {
            return false
        }
    }
}
