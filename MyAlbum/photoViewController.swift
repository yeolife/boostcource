//
//  photoViewController.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/12.
//

import UIKit
import Photos

class photoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK: - 변수
    
    var selectedTitle: String = ""
    var selectedPhotos = PHFetchResult<PHAsset>()
    let cellIdentifier_photos: String = "cell"
    
    
    // MARK: - IB
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var collectionView_photo: UICollectionView!
    
    
    // MARK: - 뷰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView_photo.delegate = self
        self.collectionView_photo.dataSource = self
        
        self.navigationItem.title = selectedTitle
        
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        self.collectionView_photo.collectionViewLayout = flowLayout
    }
    
    // 1. 선택 버튼을 누르면 벌어지는 일
    // 선택이 취소로 바뀜
    // 1장 선택전에 공유, 삭제 버튼은 비활성화 <--> 최신순 정렬은 활성화
    // 1장 선택되면 공유, 석제 버튼은 활성화  <--> 최신순 정렬이 비활성화
    
    
    // MARK: - 컬렉션 뷰
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace: CGFloat = 2 * (3 - 1)
        let cellWidth = (photoInfo.shared.screenWidth - itemSpace) / 3
        
        print(cellWidth)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier_photos, for: indexPath) as? photosCollectionViewCell else {
            fatalError("Unable to dequeue AlbumCollectionViewCell")
        }
        
        let asset: PHAsset = selectedPhotos.object(at: indexPath.item)
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
