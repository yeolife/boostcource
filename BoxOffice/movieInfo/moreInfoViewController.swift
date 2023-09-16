//
//  moreInfoViewController.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/08.
//

import UIKit

class moreInfoViewController: UIViewController, UITableViewDelegate, ImageCellDelegate, replyHeaderDelegate {
    lazy var getID: String = ""
    lazy var getTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addTable()
        
        configureTable()
        
        tableView.delegate = self
                
        singletone.shared.setupLayout(for: self)
        
        navigationItem.title = getTitle
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "영화목록",
                                                                                              style: .plain,
                                                                                              target: nil,
                                                                                              action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveMoreDataNotification),
                                               name: DidReceiveMoreDataNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveMoreDataNotification),
                                               name: DidReceiveMoreReplyNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveWritingNotification),
                                               name: DidReceiveWritingNotification,
                                               object: nil)
        
        dataRequest(getURL: "http://connect-boxoffice.run.goorm.io/movie?id=", ID: getID, type: "info")
        dataRequest(getURL: "http://connect-boxoffice.run.goorm.io/comments?movie_id=", ID: getID, type: "reply")
        
        setDataSource()
        
        setSnapshot()
    }
    
    
    // MARK: 0.테이블 뷰 Layout
    
    var tableView = UITableView()
    
    private func addTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.automaticallyAdjustsScrollIndicatorInsets = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    let cellIdentifier1: String = "cell1"
    let cellIdentifier2: String = "cell2"
    let cellIdentifier3: String = "cell3"
    let cellIdentifier4: String = "cell4"
    
    private func configureTable() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        
        tableView.register(moreInfoCell.self,
                           forCellReuseIdentifier: cellIdentifier1)
        tableView.register(moreContentCell.self,
                           forCellReuseIdentifier: cellIdentifier2)
        tableView.register(moreDirectorCell.self,
                           forCellReuseIdentifier: cellIdentifier3)
        tableView.register(moreReplyCell.self,
                           forCellReuseIdentifier: cellIdentifier4)
    }
    
    
    // MARK: 0.테이블 뷰 Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { // section별 헤더 UI
        switch section {
        case 1:
            return headerComment()
        case 2:
            return headerDirector()
        case 3:
            let header = headerReply()
            header.delegate = self
            
            return header
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { // 헤더 자동 크기
        switch section {
        case 1, 2, 3:
            return UITableView.automaticDimension
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { // 헤더 예상 크기
        switch section {
        case 1, 2, 3:
            return UITableView.automaticDimension
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    
    // MARK: 0.딜리게이트
    
    func imageTapped(_ image: UIImage) { // 셀의 이미지를 클릭을 감지해서 이미지 확대하기
        let newImageView = UIImageView(image: image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(dismissTap)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.view.insertSubview(newImageView, at: self.view.subviews.count)
    }
    
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) { // 확대한 이미지 닫기
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    
    func tapWriteButton() { // 헤더뷰의 버튼을 클릭을 감지
        guard let nextVC: writeViewController = storyboard?.instantiateViewController(withIdentifier: "writeViewController") as? writeViewController else { return }
        
        nextVC.getID = infoItem.id
        nextVC.getTitle = infoItem.title
        nextVC.getGrage = infoItem.grade
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    
    // MARK: 1. Notification
    
    @objc func didReceiveMoreDataNotification(_ noti: Notification) { // 서버에 요청한 데이터 받기
        switch noti.name {
        case DidReceiveMoreDataNotification:
            guard let movie: movieMoreAPI.moreInfoFormat = noti.userInfo?["info"] as? movieMoreAPI.moreInfoFormat else { return }
            infoItem = movie
            contentItem.synopsis = movie.synopsis
            directorItem.actor = movie.actor
            directorItem.director = movie.director
            
            DispatchQueue.main.async {
                self.setSnapshot(section: 0)
                self.setSnapshot(section: 1)
                self.setSnapshot(section: 2)
            }
        case DidReceiveMoreReplyNotification:
            guard let comments: [movieMoreAPI.moreReplyFormat] = noti.userInfo?["reply"] as? [movieMoreAPI.moreReplyFormat] else { return }
            replyItem = comments
            
            DispatchQueue.main.async {
                self.setSnapshot(section: 3)
            }
        default:
            return
        }
    }
    
    
    // 댓글 작성 시 반영
    @objc func didReceiveWritingNotification(_ noti: Notification) {
        DispatchQueue.main.async {
            dataRequest(getURL: "http://connect-boxoffice.run.goorm.io/comments?movie_id=",
                        ID: self.getID,
                        type: "reply")
        }
    }
    
    
    // Cell Section/Item
    
    var infoItem: movieMoreAPI.moreInfoFormat = movieMoreAPI.moreInfoFormat(audience: 0,
                                                                            grade: 0,
                                                                            actor: "",
                                                                            duration: 0,
                                                                            reservation_grade: 0,
                                                                            title: "",
                                                                            reservation_rate: 0,
                                                                            user_rating: 0,
                                                                            date: "",
                                                                            director: "",
                                                                            id: "",
                                                                            image: "",
                                                                            synopsis: "",
                                                                            genre: "")
    var contentItem: movieMoreAPI.moreContentFormat = movieMoreAPI.moreContentFormat(synopsis: "")
    var directorItem: movieMoreAPI.moreDirectorFormat = movieMoreAPI.moreDirectorFormat(director: "", actor: "")
    var replyItem: [movieMoreAPI.moreReplyFormat] = []
    
    enum Section: CaseIterable {
        case info
        case content
        case director
        case reply
    }
    
    enum Item: Hashable {
        case info(movieMoreAPI.moreInfoFormat)
        case content(movieMoreAPI.moreContentFormat)
        case director(movieMoreAPI.moreDirectorFormat)
        case reply(movieMoreAPI.moreReplyFormat)
    }
    
    
    // MARK: 2. 데이터 소스
    
    var dataSource: UITableViewDiffableDataSource<Section, Item>!
    
    func setDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: self.tableView ,
                                                   cellProvider: { tableView, indexPath, item -> UITableViewCell in
            
            // let section = Section.allCases[indexPath.section]
            switch item {
            case .info(let infoItem): // 2-1. 영화정보 cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier1, for: indexPath) as? moreInfoCell else {
                    fatalError("Unable to dequeue CollectionViewCell")
                }
                
                cell.delegate = self
                                
                cell.moviePoster.image = nil
                
                DispatchQueue.global().async {
                    guard let imageURL: URL = URL(string: infoItem.image) else { return }
                    guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
                    DispatchQueue.main.async {
                        if let index: IndexPath = tableView.indexPath(for: cell) {
                            if(index.row == indexPath.row) {
                                cell.moviePoster.image = UIImage(data: imageData)
                                cell.setNeedsLayout()
                                cell.layoutIfNeeded()
                            }
                        }
                    }
                }
                
                cell.movieTitle.text = infoItem.title
                
                switch infoItem.grade {
                case 0:
                    cell.movieAge.image = UIImage(named: "ic_allages")
                case 12:
                    cell.movieAge.image = UIImage(named: "ic_12")
                case 15:
                    cell.movieAge.image = UIImage(named: "ic_15")
                case 19:
                    cell.movieAge.image = UIImage(named: "ic_19")
                default:
                    print("이미지가 없습니다")
                }
                
                cell.movieDate.text = infoItem.date+" 개봉"
                cell.movieGenre.text = infoItem.genre+"/\(infoItem.duration)분"
                cell.movieReservationRate.text = String("\(infoItem.reservation_grade)위 \(infoItem.reservation_rate)%")
                
                cell.movieGradePoint.text = String(infoItem.user_rating)
                
                let cnt: Int = Int(infoItem.user_rating)/2
                for i in 0..<cnt {
                    cell.movieFiveStars[i].image = UIImage(named: "ic_star_large_full")
                }
                
                if(Int(infoItem.user_rating)%2 != 0) {
                    cell.movieFiveStars[cnt].image = UIImage(named: "ic_star_large_half")
                }
                
                var audienceStr: String = String(infoItem.audience)
                let length: Int = (audienceStr.count)
                
                for i in stride(from: (length-3), to: 0, by: -3) {
                    audienceStr.insert(",", at: audienceStr.index(audienceStr.startIndex, offsetBy: i))
                }
                
                cell.movieAudienceCount.text = audienceStr
                
                return cell
            case .content(let contentItem): // 2-2. 영화설명 cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier2, for: indexPath) as? moreContentCell else {
                    fatalError("Unable to dequeue CollectionViewCell")
                }
                
                cell.content.text = contentItem.synopsis
                
                return cell
            case .director(let directorItem): // 2-3. 영화출연 cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier3, for: indexPath) as? moreDirectorCell else {
                    fatalError("Unable to dequeue CollectionViewCell")
                }
                
                cell.director.text = directorItem.director
                cell.actor.text = directorItem.actor
                
                return cell
            case .reply(let replyItem): // 2-4. 영화댓글 cell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier4, for: indexPath) as? moreReplyCell else {
                    fatalError("Unable to dequeue CollectionViewCell")
                }
                
                cell.userProfileImage.image = UIImage(named: "ic_user_loading")
                cell.userName.text = replyItem.writer
                
                let cnt: Int = Int(replyItem.rating)/2
                for i in 0..<cnt {
                    cell.userFiveStars[i].image = UIImage(named: "ic_star_large_full")
                }
                
                if(Int(replyItem.rating)%2 != 0) {
                    cell.userFiveStars[cnt].image = UIImage(named: "ic_star_large_half")
                }
                
                let date = Date(timeIntervalSince1970: replyItem.timestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                cell.userDate.text = dateFormatter.string(from: date)
                cell.userContent.text = replyItem.contents
                
                return cell
            }
        })
    }
    
    
    // MARK: 3. 스냅샷
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    func setSnapshot() { // 3-1. section 추가
        snapshot.appendSections([.info, .content, .director, .reply])
    }
    
    func setSnapshot(section: Int) { // 3-2. item 추가
        switch section {
        case 0:
            snapshot.appendItems([.info(infoItem)], toSection: .info)
        case 1:
            snapshot.appendItems([.content(contentItem)], toSection: .content)
        case 2:
            snapshot.appendItems([.director(directorItem)], toSection: .director)
        case 3:
            snapshot.appendItems(replyItem.map { .reply($0) }, toSection: .reply)
        default:
            return
        }
        
        self.dataSource.apply(snapshot)
    }
}


// Unix Timestamp
extension Date {
    static var timestamp: Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}
