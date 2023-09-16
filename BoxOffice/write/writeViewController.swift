//
//  writeViewController.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/15.
//

import UIKit

class writeViewController: UIViewController, UITextViewDelegate {
    
    lazy var getID: String = ""
    lazy var getTitle: String = "영화제목"
    lazy var getGrage: Int = 0
    
    @IBOutlet weak var movieTitle: UILabel?
    @IBOutlet weak var movieAge: UIImageView?
    
    @IBOutlet weak var star1: UIImageView?
    @IBOutlet weak var star2: UIImageView?
    @IBOutlet weak var star3: UIImageView?
    @IBOutlet weak var star4: UIImageView?
    @IBOutlet weak var star5: UIImageView?
    @IBOutlet weak var starCount: UILabel?
    
    @IBOutlet weak var IDField: UITextField?
    @IBOutlet weak var contentField: UITextView?
    let placeholder = "후기를 남겨주세요 :)"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveWritingNotification),
                                               name: DidReceiveWritingNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveErrorNotification),
                                               name: DidReceiveErrorNotification,
                                               object: nil)
        
        setupNaviBar()
        
        setObjects()
        
        singletone.shared.setupLayout(for: self)
    }
    
    
    func setupNaviBar() {
        self.navigationItem.title = "한줄평 작성"

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "취소",
                                                                                              style: .plain,
                                                                                              target: nil,
                                                                                              action: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(touchUpWriteCompleteButton))
    }
    
    
    private func setObjects() {
        movieTitle?.text = getTitle
        
        IDField?.text = singletone.shared.replyNickname != nil ? singletone.shared.replyNickname : nil
        
        contentField?.layer.borderWidth = 0.8
        contentField?.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        contentField?.layer.cornerRadius = 5
        contentField?.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        contentField?.font = .systemFont(ofSize: 14)
        contentField?.text = placeholder
        contentField?.textColor = .lightGray
        contentField?.delegate = self
        
        switch getGrage {
        case 0:
            movieAge?.image = UIImage(named: "ic_allages")
        case 12:
            movieAge?.image = UIImage(named: "ic_12")
        case 15:
            movieAge?.image = UIImage(named: "ic_15")
        case 19:
            movieAge?.image = UIImage(named: "ic_19")
        default:
            movieAge?.image = UIImage(named: "ic_allages")
        }
    }
    
    
    // 텍스트뷰의 플레이스 홀더
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
    
    
    // 투명 슬라이더로 별점을 업데이트
    var intValue: Int = 0
    @IBAction func onDragStarSlider(_ sender: UISlider) {
        intValue = Int(floor(sender.value))
        
        for index in 0...5 { // 여기서 index는 설정한 'Tag'로 매치
            if let starImage = view.viewWithTag(index) as? UIImageView {
                if (index <= intValue / 2) {
                    starImage.image = UIImage(named: "ic_star_large_full")
                }
                else {
                    if (2 * index - intValue) <= 1 {
                        starImage.image = UIImage(named: "ic_star_large_half")
                    }
                    else {
                        starImage.image = UIImage(named: "ic_star_large")
                    }
                }
            }
            starCount?.text = String(intValue)
        }
    }
    
    
    // 글쓰기 완료버튼
    @IBAction func touchUpWriteCompleteButton() {
        // 닉네임과 한줄평이 비어있는지 확인하고 경고 알림
        if(IDField?.text?.isEmpty == true || contentField?.text == placeholder || contentField?.text.isEmpty == true) {
            if(IDField?.text?.isEmpty == true) {
                IDField?.layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor
                IDField?.layer.borderWidth = 0.5
                IDField?.layer.cornerRadius = 5
            }
            else {
                singletone.shared.replyNickname = IDField?.text ?? ""
                IDField?.layer.borderColor = nil
            }
            
            if(contentField?.text == placeholder || contentField?.text.isEmpty == true) {
                contentField?.layer.borderColor = UIColor.red.withAlphaComponent(0.3).cgColor
            }
            else {
                contentField?.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
            }
            
            alertPopUp(msg: "비어있는 칸이 존재합니다.")
        }
        else {
            var review: reviewWrite
            
            review = reviewWrite(rating: Double(intValue),
                                 timestamp: Date().timeIntervalSince1970,
                                 writer: IDField?.text ?? "",
                                 movie_id: getID,
                                 contents: contentField?.text ?? "")
            // 서버에 글 전송
            dataResponse(writingData: review,
                         urlAddress: "http://connect-boxoffice.run.goorm.io/comment")
        }
    }
    
    // 서버에 글 작성 Notification
    @objc func didReceiveWritingNotification(_ noti: Notification) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func didReceiveErrorNotification(_ noti: Notification) {
        alertPopUp(msg: "데이터를 불러오지 못했습니다.")
    }
    
    
    private func alertPopUp(msg: String) {
        let alert = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }
}
