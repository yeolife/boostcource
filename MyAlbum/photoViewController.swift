//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos

class photoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    // MARK: - 클래스 변수
    var albumIndex: Int!
    var albumInTitle: String = ""
    var albumInPhotos : PHFetchResult<PHAsset>!
    var albumInCollection: PHAssetCollection!
    let cellIdentifier_photos: String = "cell"
    @IBOutlet weak var collectionView_photo: UICollectionView!
    
    
    // MARK: - 사진 선택 이벤트
    
    // 사진 선택으로 인한 초기화
    func selectInit() {
        sortButton.isEnabled = false // 정렬 비활성화
        
        multiSelectStatus = true // 사진 다중선택 활성화
    }
    
    // 사진 선택 취소로 인한 초기화
    func cancleInit() {
        sortButton.isEnabled = true // 정렬 활성화
        shareButton.isEnabled = false // 공유 비활성화
        deleteButton.isEnabled = false // 삭제 비활성화
        
        multiSelectStatus = false // 사진 다중선택 비활성화
        
        selectCount = 0
        
        // 모든 셀의 투명도를 원래되로 되돌림
        for index in selectPhotos {
            collectionView_photo.cellForItem(at: index)?.alpha = 1.0
        }
        
        selectPhotos.removeAll()
    }
    
    var selectStatus: Bool = true
    var multiSelectStatus: Bool = false
    var selectCount: Int = 0
    var selectPhotos: Set<IndexPath> = []
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBAction func touchUpSelectButton(_ sender: UIBarButtonItem) {
        if(selectStatus) {
            self.selectInit()
            self.navigationItem.title = "항목 선택"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
        else {
            self.cancleInit()
            self.navigationItem.title = albumInTitle
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
        }
        
        selectStatus = !selectStatus
    }
    
    
    // MARK: - 선택 사진 삭제 이벤트
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    @IBAction func touchUpShareButton(_ sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: - 선택 사진 삭제 이벤트
    
    @IBOutlet weak var deleteButton: UIBarButtonItem! {
        didSet {
            deleteButton.isEnabled = false
        }
    }
    @IBAction func touchUpDeleteButton(_ sender: UIBarButtonItem) {
        var deleteListAsset = [PHAsset]()
        
        for index in selectPhotos {
            deleteListAsset.append(albumInPhotos[index.item])
        }
        
        PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(deleteListAsset as NSFastEnumeration)},
                                               completionHandler: { (success, error) in
                                                if (success) {
                                                    OperationQueue.main.addOperation {
                                                        self.shareButton.isEnabled = false // 공유 비활성화
                                                        self.deleteButton.isEnabled = false // 삭제 비활성화
                                                        
                                                        self.selectCount = 0
                                                        self.selectPhotos.removeAll()
                                                        
                                                        self.navigationItem.title = "항목 선택"
                                                    }
                                                }
                                                else {
                                                    print("삭제 이벤트에서 오류 발생")
                                                }
        })
    }
    
    
    // MARK: - 사진 정렬 이벤트
    
    var sortStatus: Bool = false
    @IBOutlet weak var sortButton: UIButton!
    @IBAction func touchUpSortButton(_ sender: UIButton) {
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
    
    
    // MARK: - UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_photo.delegate = self
        self.collectionView_photo.dataSource = self
                
        self.navigationItem.title = albumInTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchUpSelectButton(_:)))
                
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        self.collectionView_photo.collectionViewLayout = flowLayout
        
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        albumInPhotos = PHAsset.fetchAssets(in: albumInCollection, options: sortDate)
        
        PHPhotoLibrary.shared().register(self) // 변화감지 옵저버
    }
    
    
    // MARK: - 사진
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumInPhotos)
            else { return }
        
        albumInPhotos = changes.fetchResultAfterChanges
        
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier_photos, for: indexPath) as? photosCollectionViewCell else {
            fatalError("Unable to dequeue AlbumCollectionViewCell")
        }
        
        let asset: PHAsset = albumInPhotos.object(at: indexPath.item)
        photoInfo.shared.options.isSynchronous = false
        photoInfo.shared.imageManager.requestImage(for: asset,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: .aspectFill,
                                                   options: photoInfo.shared.options,
                                  resultHandler: {image, _ in cell.imageView_photo?.image = image})
        
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    // 셀 선택 시 발생
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(multiSelectStatus) {
            if(!selectPhotos.contains(indexPath)) { // 선택되지 않은 사진을 누르면
                selectCount += 1
                selectPhotos.insert(indexPath)
                collectionView.cellForItem(at: indexPath)?.alpha = 0.7 // 이미지 선택 시 투명도
            }
            else { // 이미 선택된 사진을 다시 누르면
                selectCount -= 1
                selectPhotos.remove(indexPath)
                collectionView.cellForItem(at: indexPath)?.alpha = 1.0
            }
            
            if(selectCount == 1) { // 선택된 사진이 있으면
                shareButton.isEnabled = true // 공유 버튼 활성화
                deleteButton.isEnabled = true // 삭제 버튼 활성화
            }
            else if(selectCount == 0) { // 선택된 사진이 없으면
                navigationItem.title = "항목 선택"
                shareButton.isEnabled = false // 공유 버튼 비활성화
                deleteButton.isEnabled = false // 삭제 버튼 비활성화
            }
            
            navigationItem.title = "\(selectCount)장 선택"
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
