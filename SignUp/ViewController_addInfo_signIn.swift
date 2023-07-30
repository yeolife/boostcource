//
//  ViewController_addInfo_signIn.swift
//  SignUp
//
//  Created by yeolife on 2023/07/27.
//

import UIKit

class ViewController_addInfo_signIn: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter
    }()
    
    // MARK: - IBAction
    
    @IBAction func didDatePickerValueChanged(_ sender: UIDatePicker) {
        print("날짜 변경!")
        
        let date: Date = self.datePicker.date
        let dateString: String = self.dateFormatter.string(from: date)
        
        self.dateLabel.text = dateString
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datePicker.addTarget(self, action: #selector(self.didDatePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Function
    
    // 회원가입 취소하기
    @IBAction func dismiss_signUp() {
        self.dismiss(animated: true, completion: nil)
    }


    // 화원가입 중에 이전화면 돌아가기(부가정보 페이지 -> 필수정보 페이지)
    @IBAction func popPrev_signUp() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // 회원가입 성공
    @IBAction func getUserInformation_signUp() {
        
    }
}
