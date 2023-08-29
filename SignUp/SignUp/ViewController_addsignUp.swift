//
//  ViewController_addInfo_signUp.swift
//  SignUp
//
//  Created by yeolife on 2023/07/27.
//

import UIKit
import Foundation
import Security

class ViewController_addsignUp: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var phoneNum_TextField_signUp: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.datePicker.addTarget(self, action: #selector(self.didDatePickerValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Function
    
    // 회원가입 취소하기
    @IBAction func dismiss_signUp() {
        cancleAddUserInformaiton_signUp(num: 1)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didDatePickerValueChanged(_ sender: UIDatePicker) {
        let date: Date = self.datePicker.date
        let dateString: String = self.dateFormatter.string(from: date)
        
        self.dateLabel.text = dateString
    }

    // 화원가입 중에 이전화면 돌아가기(부가정보 페이지 -> 필수정보 페이지)
    @IBAction func popPrev_signUp() {
        cancleAddUserInformaiton_signUp(num: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    // 회원가입 성공
    @IBAction func getUserInformation_signUp() {
        userInformation.shared.user_phoneNum = phoneNum_TextField_signUp.text
        userInformation.shared.user_birthday = dateLabel.text

        self.dismiss(animated: true, completion: nil)
    }
    
    // 텍스트필드 빈칸으로 변경
    func cancleAddUserInformaiton_signUp(num: Int) {
        userInformation.shared.user_phoneNum = nil
        userInformation.shared.user_birthday = nil
        
        if(num == 1) {
            userInformation.shared.user_id = nil
            userInformation.shared.user_password = nil
            userInformation.shared.user_introduce = nil
            userInformation.shared.user_profile = nil
        }
    }
}
