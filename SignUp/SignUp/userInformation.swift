//
//  userInformation.swift
//  SignUp
//
//  Created by yeolife on 2023/07/24.
//

import UIKit
import Foundation

class userInformation {
    private init(){}
    static let shared = userInformation()

    var user_id: String?
    var user_password: String?
    var user_introduce: String?
    var user_profile: UIImage?
    
    var user_phoneNum: String?
    var user_birthday: String?
}
