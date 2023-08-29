//
//  ViewController_Login.swift
//  SignUp
//
//  Created by yeolife on 2023/07/31.
//

import UIKit

class ViewController_Login: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var Login_id: UILabel!
    @IBOutlet weak var Login_phoneNum: UILabel!
    @IBOutlet weak var Login_birthday: UILabel!
    @IBOutlet weak var Login_introduce: UITextView!
    @IBOutlet weak var Login_profile: UIImageView!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.Login_id.text = "\(userInformation.shared.user_id!)님 환영합니다!"
        self.Login_phoneNum.text = userInformation.shared.user_phoneNum
        self.Login_birthday.text = userInformation.shared.user_birthday
        self.Login_introduce.text = userInformation.shared.user_introduce
        self.Login_profile.image = userInformation.shared.user_profile
        
        print("SecondViewController의 view가 화면에 보여질 예정")
    }
}
