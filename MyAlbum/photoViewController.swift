//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos

protocol reloadDelegate { // 앨범을 새로고침 해주는 딜리게이트
    func reloadView(msg: String)
}

class photoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    // + 다음 뷰
        
    // MARK: - 클래스 변수
    
    var albumIndex: Int!
    var albumInTitle: String = ""
    var albumInPhotos : PHFetchResult<PHAsset>!
    var albumInCollection: PHAssetCollection!
    let cellIdentifier_photos: String = "cell"
    var photoViewDelegate: reloadDelegate?
    @IBOutlet weak var collectionView_photo: UICollectionView!
    
    
    // MARK: - 사진 정렬
    
    var sortStatus: Bool = false
    @IBOutlet weak var sortButton: UIButton!
    @IBAction func touchUpSortButton(_ sender: UIButton) {
        sortPhoto()
    }
    
    // 사진 정렬 이벤트
    func sortPhoto() {
        if(!sortStatus) {
            sortButton.setTitle("과거순", for: .normal)
        }
        else {
            sortButton.setTitle("최신순", for: .normal)
        }
        sortStatus = !sortStatus
        
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortStatus)]
 
        albumInPhotos = PHAsset.fetchAssets(in: albumInCollection, options: sortDate)
      
        self.collectionView_photo.reloadSections(IndexSet(0...0))
    }
    
    
    // MARK: - 사진 선택
    
    var multiSelectStatus: Bool = false
    var selectPhotos: Set<IndexPath> = []
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBAction func touchUpSelectButton(_ sender: UIBarButtonItem) {
        selectPhoto()
    }
    
    // 사진 선택 이벤트
    func selectPhoto() {
        multiSelectStatus = !multiSelectStatus
        
        if(multiSelectStatus) {
            sortButton.isEnabled = false // 정렬 비활성화
            
            self.navigationItem.title = "항목 선택"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
        else {
            self.cancleInit()
            
            sortButton.isEnabled = true // 정렬 활성화
            
            self.navigationItem.title = albumInTitle
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
    }
    
    // 사진 선택 취소로 인한 초기화
    func cancleInit() {
        shareButton.isEnabled = false // 공유 비활성화
        deleteButton.isEnabled = false // 삭제 비활성화
                        
        // 모든 셀의 투명도를 원래되로 되돌림
        OperationQueue.main.addOperation {
            for index in self.selectPhotos {
                self.collectionView_photo.cellForItem(at: index)?.layer.opacity = 1.0
                self.collectionView_photo.cellForItem(at: index)?.layer.borderWidth = .zero
            }
        }
        
        selectPhotos.removeAll()
    }
    
    
    // MARK: - 선택 사진 공유
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    
    // 선택 사진 공유 이벤트
    @IBAction func touchUpShareButton(_ sender: UIBarButtonItem) {
        sharePhoto()
    }
    
    func sharePhoto() {
        var sharePhotos = [UIImage]()
        
        photoInfo.shared.options.deliveryMode = .highQualityFormat
        photoInfo.shared.options.isSynchronous = true
        
        for sharePhoto in selectPhotos {
            photoInfo.shared.imageManager.requestImage(for: albumInPhotos[sharePhoto.item],
                                                       targetSize: PHImageManagerMaximumSize,
                                                       contentMode: .aspectFit,
                                                       options: photoInfo.shared.options)
            { (image, info) in sharePhotos.append(image!)}
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharePhotos, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, success, returnedItems, error) in
            if(success && activityType == UIActivity.ActivityType.saveToCameraRoll) {
                self.shareInit()
            }
        }
        
        // 아이패드용 팝업
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
//                                                                                  y: view.bounds.midY,
//                                                                                  width: 0, height: 0)
//        activityViewController.popoverPresentationController?.permittedArrowDirections = .up
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // share 사진을 앨범에 저장하는 경우, 이후에 선택한 사진의 인덱스 조정해야함
    func shareInit() {
        selectPhotos = Set(selectPhotos.map { IndexPath(row: $0.row + selectPhotos.count, section: $0.section) })
    }
    
    
    // MARK: - 선택 사진 삭제
    
    @IBOutlet weak var deleteButton: UIBarButtonItem! {
        didSet {
            deleteButton.isEnabled = false
        }
    }
    
    @IBAction func touchUpDeleteButton(_ sender: UIBarButtonItem) {
        deletePhoto()
    }
    
    // 선택 사진 삭제 이벤트
    func deletePhoto() {
        var deleteListAsset = [PHAsset]()
        
        for index in selectPhotos {
            deleteListAsset.append(albumInPhotos[index.item])
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
    
    
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_photo.delegate = self
        self.collectionView_photo.dataSource = self
        
        self.navigationItem.title = albumInTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        
        // flowLayout
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        self.collectionView_photo.collectionViewLayout = flowLayout
        
        // 사진들 전처리
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        albumInPhotos = PHAsset.fetchAssets(in: albumInCollection, options: sortDate)
        
        PHPhotoLibrary.shared().register(self) // 변화감지 옵저버
    }
    
    func onSelected(index: IndexPath) {
        OperationQueue.main.addOperation {
            self.collectionView_photo.cellForItem(at: index)?.layer.opacity = 0.7
            self.collectionView_photo.cellForItem(at: index)?.layer.borderWidth = 2
            self.collectionView_photo.cellForItem(at: index)?.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    func onDeselected(index: IndexPath) {
        OperationQueue.main.addOperation {
            self.collectionView_photo.cellForItem(at: index)?.layer.opacity = 1.0
            self.collectionView_photo.cellForItem(at: index)?.layer.borderWidth = .zero
            self.collectionView_photo.cellForItem(at: index)?.layer.borderColor = nil
        }
    }
    
    
    // MARK: - 사진 변화 옵저버
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumInPhotos)
            else { return }
        
        albumInPhotos = changes.fetchResultAfterChanges
        
        self.photoViewDelegate?.reloadView(msg: "앨범 내 사진 추가 또는 삭제 발생")
        
        OperationQueue.main.addOperation {
            self.collectionView_photo.reloadSections(IndexSet(0...0))
        }
    }
    
    
    // MARK: - 컬렉션 뷰

    // 셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace: CGFloat = 2 * (3 - 1)
        let cellWidth = (photoInfo.shared.screenWidth - itemSpace) / 3
                
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumInPhotos?.count ?? 0
    }
    
    // 셀 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: self.cellIdentifier_photos,
            for: indexPath) as? photoCollectionViewCell else {
            fatalError("Unable to dequeue AlbumCollectionViewCell")
        }
                
        let asset: PHAsset = albumInPhotos.object(at: indexPath.item)
        photoInfo.shared.options.isSynchronous = false
        photoInfo.shared.imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFill,
                                                   options: photoInfo.shared.options,
                                  resultHandler: {image, _ in cell.imageView_photo?.image = image})
        
        if(self.selectPhotos.contains(indexPath) == false) {
            self.onDeselected(index: indexPath)
        }
        else {
            self.onSelected(index: indexPath)
        }
        
        return cell
    }
    
    // 셀 선택 시 발생
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(multiSelectStatus) {
            if(selectPhotos.contains(indexPath) == false) { // 선택되지 않은 사진을 누르면
                selectPhotos.insert(indexPath)
                
                onSelected(index: indexPath)
            }
            else { // 이미 선택된 사진을 다시 누르면
                selectPhotos.remove(indexPath)
                
                onDeselected(index: indexPath)
            }
            
            if(selectPhotos.count == 1) { // 선택된 사진이 있으면
                shareButton.isEnabled = true // 공유 버튼 활성화
                deleteButton.isEnabled = true // 삭제 버튼 활성화
            }
            else if(selectPhotos.count == 0) { // 선택된 사진이 없으면
                shareButton.isEnabled = false // 공유 버튼 비활성화
                deleteButton.isEnabled = false // 삭제 버튼 비활성화
            }
            
            if(selectPhotos.count >= 1) {
                navigationItem.title = "\(selectPhotos.count)장 선택"
            }
            else {
                navigationItem.title = "항목 선택"
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
