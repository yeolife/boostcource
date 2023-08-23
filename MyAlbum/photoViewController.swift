//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos

protocol reloadDelegate { // 앨범을 새로고침 해주는 딜리게이트
    func reloadView(msg: String, indexPath: IndexPath)
}

class photoViewController: UIViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    
    // -----------------------------------------
    // MARK: - 클래스 변수
    
    var albumTitle: String = ""
    var albumIndexPath: IndexPath = IndexPath()
    
    var albumInImages: [Item] = []
    var albumInPhotos : PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    var collectionAlbum: PHAssetCollection!
    
    let cellIdentifier_photos: String = "cell"
    @IBOutlet weak var collectionView_photo: UICollectionView!
    
    var photoViewDelegate: reloadDelegate?
    
    
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

        setupPhotos(state: sortStatus)
        
        setupSnapshot()
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
            self.cancleInit()
                        
            self.navigationItem.title = albumTitle
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
    }
    
    
    // 사진 선택 취소로 인한 초기화
    func cancleInit() {
        shareButton.isEnabled = false // 공유 비활성화
        deleteButton.isEnabled = false // 삭제 비활성화
        sortButton.isEnabled = true
        
        var snapshot = dataSource.snapshot()

        for item in selectPhotos {
            if let index = albumInImages.firstIndex(where: { $0.uuid == item.uuid }) {
                albumInImages[index].onSelected = false
                snapshot.reloadItems([item])
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
        selectPhotos.removeAll()
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
        
        for item in selectPhotos {
            sharePhotos.append(photoInfo.shared.assetToImage(asset: item.asset))
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharePhotos, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, success, returnedItems, error) in
            if(success && activityType == UIActivity.ActivityType.saveToCameraRoll) {
                self.cancleInit()
                self.navigationItem.title = "항목 선택"
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
        var deleteListAsset = [PHAsset]()
        
        for item in selectPhotos {
            deleteListAsset.append(item.asset)
        }
                
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(deleteListAsset as NSFastEnumeration)},
                                               completionHandler: { (success, error) in
                                                if (success) {
                                                    OperationQueue.main.addOperation {
                                                        self.cancleInit()
                                                        self.navigationItem.title = "항목 선택"
                                                    }
                                                }
                                                else {
                                                    print("삭제 취소 또는 오류 발생")
                                                }})
    }

    
    // -----------------------------------------
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_photo.delegate = self
        
        setupNavigationBar()
        
        setupLayout()
        
        setupPhotos(state: false)
        
        setupDataSource()
        
        setupSnapshot()
        
         PHPhotoLibrary.shared().register(self) // 변화감지 옵저버
    }
    
    
    func setupNavigationBar() {
        self.navigationItem.title = albumTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
    }
    
    
    func setupLayout() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        
        self.collectionView_photo.collectionViewLayout = flowLayout
    }
    
    
    func setupPhotos(state: Bool) { // 사진들 전처리
        photoInfo.shared.sortDate(state: state)
        
        albumInPhotos = PHAsset.fetchAssets(in: collectionAlbum, options: photoInfo.shared.sortOption)
        
        albumInImages = albumInPhotos.objects(at: IndexSet(integersIn: 0..<albumInPhotos.count)).map { Item(asset: $0) }
    }
    
    
    // -----------------------------------------
    // MARK: - 사진 변화 감지
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumInPhotos)
            else { return }
        
        albumInPhotos = changes.fetchResultAfterChanges
        
        self.photoViewDelegate?.reloadView(msg: "앨범 내 사진 추가 또는 삭제 발생", indexPath: albumIndexPath)
        
        self.setupPhotos(state: self.sortStatus)
        
        self.setupSnapshot()
    }
    
    
    // -----------------------------------------
    // MARK: - 컬렉션 뷰
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    
    enum Section: CaseIterable {
        case album
    }
    
    
    class Item: Hashable {
        var uuid: UUID = UUID()
        var asset: PHAsset
        var image = UIImage()
        var onSelected: Bool = false
        init(asset: PHAsset) {
            self.asset = asset
            self.image = photoInfo.shared.assetToImage(asset: self.asset)
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
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.collectionView_photo,
                                                                            cellProvider: {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: self.cellIdentifier_photos,
                for: indexPath) as? photoCollectionViewCell else {
                fatalError("Unable to dequeue AlbumCollectionViewCell")
            }
            
            cell.imageView_photo.image = item.image
            cell.clickImageView(state: item.onSelected)
            
            return cell
        })
    }
    
    
    // 셀 내용 (스냅샷)
    func setupSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.album])

        snapshot.appendItems(albumInImages)
                
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // 셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace: CGFloat = 2 * (3 - 1)
        let cellWidth = (photoInfo.shared.screenWidth - itemSpace) / 3
                
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
        
        guard let indexPath: IndexPath = self.collectionView_photo.indexPath(for: cell) else {
            return
        }
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        nextVC.singlePhotoAsset = item.asset
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
