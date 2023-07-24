//
//  ViewController_signIn.swift
//  SignUp
//
//  Created by yeolife on 2023/07/25.
//

import UIKit

class ViewController_signIn: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var inputCheck_TextField_signUp: UITextField!
    @IBOutlet weak var introduce_signUp: UITextView!
    @IBOutlet weak var nextBtn: UIButton! {
        didSet {
            nextBtn.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputCheck_TextField_signUp.delegate = self
    }
    
    // 회원가입 취소하기
    @IBAction func dismiss_signUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 텍스트 변경을 추적하여 빈칸 확인
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if(range.location > 0) {
            self.nextBtn.isEnabled = true
        }
        else {
            self.nextBtn.isEnabled = false
        }
        
        return true
    }
    
    
    // 비밀번호가 같은지 확인
    
 
    
    // 조건을 만족하면 버튼 활성화
    
    
    
    // 화원가입 중에 이전화면 돌아가기(부가정보 페이지 -> 필수정보 페이지)
    @IBAction func popPrev_signUp() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 회원가입 성공
    @IBAction func getUserInformation_signUp() {
        
    }
}
