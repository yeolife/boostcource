//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos


class photoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    
    // MARK: - 변수
    
    var albumIndex: Int!
    var albumInTitle: String = ""
    var albumInPhotos : PHFetchResult<PHAsset>!
    var albumInCollection: PHAssetCollection!
    let cellIdentifier_photos: String = "cell"
    
    // MARK: - IB
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBAction func touchUpSelectButton(_ sender: UIBarButtonItem) {
        // 선택 버튼을 누르면 벌어지는 일
        // 선택이 취소로 바뀜 + 제목이 항목 선택으로 바뀜
        
        // 사진 선택시 제목이 몇장 선택했는지로 바뀜
        // 이미지 선택시에 투명도
        // 1장 선택전에 공유, 삭제 버튼은 비활성화 <--> 최신순 정렬은 활성화
        // 1장 선택되면 공유, 석제 버튼은 활성화  <--> 최신순 정렬이 비활성화
        
        
    }
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    @IBOutlet weak var deleteButton: UIBarButtonItem! {
        didSet {
            deleteButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var sortButton: UIButton!
    @IBAction func touchUpSortButton(_ sender: UIButton) {
        let sortStatus: Bool = photoInfo.shared.indexAndSortStatus[albumIndex]!
        
        if(!sortStatus) {
            sortButton.setTitle("과거순", for: .normal)
        }
        else {
            sortButton.setTitle("최신순", for: .normal)
        }
        photoInfo.shared.indexAndSortStatus[albumIndex] = !sortStatus
        
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !sortStatus)]
 
        albumInPhotos = PHAsset.fetchAssets(in: albumInCollection, options: sortDate)
      
        self.collectionView_photo.reloadSections(IndexSet(0...0))
    }
    
    @IBOutlet weak var collectionView_photo: UICollectionView!
    
    
    
    // MARK: - 뷰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_photo.delegate = self
        self.collectionView_photo.dataSource = self
        
        self.navigationItem.title = albumInTitle
        
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        self.collectionView_photo.collectionViewLayout = flowLayout
        
        let sortDate = PHFetchOptions()
        sortDate.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: photoInfo.shared.indexAndSortStatus[albumIndex]!)]
        albumInPhotos = PHAsset.fetchAssets(in: albumInCollection, options: sortDate)
        
        PHPhotoLibrary.shared().register(self) // 변화감지 옵저버
    }
    
    // MARK: - 함수
    
    
    // MARK: - 사진
    
    // 변경사항이 있으면 리로드
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumInPhotos)
            else { return }
        
        albumInPhotos = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.collectionView_photo.reloadSections(IndexSet(0...0))
        }
    }
    
    
    // MARK: - 컬렉션 뷰
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace: CGFloat = 2 * (3 - 1)
        let cellWidth = (photoInfo.shared.screenWidth - itemSpace) / 3
                
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumInPhotos?.count ?? 0
    }

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
                
        return cell
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
