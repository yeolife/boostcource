//
//  listCollectionViewController.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/01.
//

import UIKit

class listCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveMovieDataNotification(_:)),
                                               name: DidReceiveMovieDataNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didChangeMovieListNotification(_:)),
                                               name: DidChangeMovieListNotification,
                                               object: nil)
        
        self.navigationItem.title = movieListData.shared.setMovieListTitle()
        
        singletone.shared.setupLayout(for: self)
        
        setupLayout()
        
        initRefresh()
        
        setDataSource()
    }
    
    
    let cellIdentifier: String = "collectionCell"
    
    @IBOutlet var collectionView: UICollectionView!
    
    // 리스트 정렬 변경
    @IBAction func touchUplistSortButton() {
        let alertController: UIAlertController
        alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: UIAlertController.Style.actionSheet)
        
        
        let handler: (UIAlertAction) -> Void
        handler = {(action: UIAlertAction) in
            
            var sortNum: Int = 0
            
            switch action.title {
            case "예매율 순":
                sortNum = 0
            case "평점 순":
                sortNum = 1
            case "개봉일 순":
                sortNum = 2
            default:
                return
            }
            
            movieListData.shared.setMovieListSort(getSortNum: sortNum)
            
            NotificationCenter.default.post(name: DidChangeMovieListNotification,
                                            object: nil,
                                            userInfo: ["sortNum" : sortNum])
 
            print("action pressed \(action.title ?? "")")
        }
        
        let sortTitleList: [String] = ["예매율 순", "평점 순", "개봉일 순"]
        
        sortTitleList.forEach { title in
            let sortSheet: UIAlertAction
            sortSheet = UIAlertAction(title: title,
                                       style: UIAlertAction.Style.default,
                                       handler: handler)
            
            alertController.addAction(sortSheet)
        }
        
        let cancleAction: UIAlertAction
        cancleAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)

        alertController.addAction(cancleAction)
        
        
        self.present(alertController, animated: true, completion: {
            print("Alert controller shown")
        })
    }
    
    
    // 리스트 새로 고침
    func initRefresh() {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refreshCollectionView(refresh:)), for: .valueChanged)
        refreshControl.backgroundColor = .gray
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "새로고침 중", attributes: [.foregroundColor: UIColor.white])
            
        self.collectionView.refreshControl = refreshControl
    }
    
    @objc func refreshCollectionView(refresh: UIRefreshControl) {
       print("새로고침 시작")
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           dataRequest(getURL: "https://connect-boxoffice.run.goorm.io/movies?order_type=\(movieListData.shared.currentSort)")
           
           refresh.endRefreshing()
       }
    }
    
   
    // notifications
    @objc func didReceiveMovieDataNotification(_ noti: Notification) {
        DispatchQueue.main.sync {
            self.setSnapshot()
        }
    }
    
    @objc func didChangeMovieListNotification(_ noti: Notification) {
        self.navigationItem.title = movieListData.shared.setMovieListTitle()
        
        // 스냅샷을 활용하여 정렬 변경
        var snapshot = datasource.snapshot()
 
        snapshot.deleteItems(movieListData.shared.movieListItem)
        
        snapshot.appendItems(movieListData.shared.movieListItem)
                
        self.datasource.apply(snapshot, animatingDifferences: true)
    }

    
    // 셀 크기
    func setupLayout() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    
    let screenWidth: CGFloat = { // 절대적인 화면 너비값 (회전 상태에서 앱 실행시 너비와 높이가 바뀌는 것을 방지)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = (self.screenWidth - 30) / 172 // 아이폰se width 기준

        let widthPadding = 8 * (itemsPerRow + 1)
        let cellWidth = (self.screenWidth - widthPadding) / itemsPerRow
        let cellHeight = cellWidth*1.5 + 16 + 80

        return CGSize(width: cellWidth, height: cellHeight)
    }

    
    // 셀 내용
    var datasource: UICollectionViewDiffableDataSource<Int, movieListFormat>!

    func setDataSource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: self.collectionView ?? UICollectionView(),
                                                   cellProvider: { collectionView, indexPath, item -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier,
                                                                 for: indexPath) as? listCollectionViewCell
            else { fatalError("Unable to dequeue CollectionViewCell") }
            
            cell.moviePoster?.image = nil
            
            DispatchQueue.global().async {
                guard let imageURL: URL = URL(string: item.thumb) else { return }
                guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
                
                DispatchQueue.main.async {
                    if let index: IndexPath = collectionView.indexPath(for: cell) {
                        if(indexPath.row == index.row) {
                            cell.moviePoster?.image = UIImage(data: imageData)
                            
                            // 즉시 적용
                            cell.setNeedsLayout()
                            cell.layoutIfNeeded()
                        }
                    }
                }
            }
            
            switch item.grade {
            case 0:
                cell.movieAge?.image = UIImage(named: "ic_allages")
            case 12:
                cell.movieAge?.image = UIImage(named: "ic_12")
            case 15:
                cell.movieAge?.image = UIImage(named: "ic_15")
            case 19:
                cell.movieAge?.image = UIImage(named: "ic_19")
            default:
                print("이미지가 없습니다")
            }
            
            cell.movieTitle?.text = item.title
            cell.movieGrade?.text = item.movieEvaluationText
            cell.movieReleaseDate?.text = item.movieDateText
            
            return cell
        })
    }
    

    func setSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, movieListFormat>()
        
        snapshot.appendSections([0])
        
        snapshot.appendItems(movieListData.shared.movieListItem)
        
        self.datasource.apply(snapshot, animatingDifferences: false)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC: moreInfoViewController = segue.destination as? moreInfoViewController else {
            return
        }
        
        guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath: IndexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        guard let item = datasource.itemIdentifier(for: indexPath) else {
            return
        }
        
        nextVC.getID = item.id
        nextVC.getTitle = item.title
    }
}
