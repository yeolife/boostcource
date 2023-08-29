//
//  ViewController.swift
//  SignUp
//
//  Created by yeolife on 2023/07/15.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var id_TextField_signIn: UITextField!
    @IBOutlet weak var pw_TextField_signIn: UITextField!
    @IBOutlet weak var btn_signIn: UIButton!
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Function
    
    // 버튼 눌렀을 때 유저정보 대조하고 팝업창
    @IBAction func checkUserBtn_signIn() {
        let sameUserId = (id_TextField_signIn.text == userInformation.shared.user_id)
        let sameUserPw = (pw_TextField_signIn.text == userInformation.shared.user_password)
        
        if(sameUserId) {
            if(sameUserPw) {
                sucessLogin()
            }
            else {
                pw_TextField_signIn.text = ""
                alertPopUp(msg: "비밀번호 틀림")
            }
            
        }
        else {
            id_TextField_signIn.text = ""
            pw_TextField_signIn.text = ""
            alertPopUp(msg: "아이디 없음")
        }
    }
    
    func sucessLogin() {
        guard let Login = self.storyboard?.instantiateViewController(identifier: "ViewController_Login")
        else { return }
        Login.modalPresentationStyle = .fullScreen
        Login.modalTransitionStyle = .crossDissolve
        self.present(Login, animated: true, completion: nil)
    }
    
    func alertPopUp(msg: String) {
        let alert = UIAlertController(title: "오류", message: msg, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }
}

