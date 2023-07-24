//
//  userInformation.swift
//  SignUp
//
//  Created by yeolife on 2023/07/24.
//

import Foundation

class userInformation {
    static let shared: userInformation = userInformation()
    
    var user_id: String?
    var user_password: String?
    var user_introduce: String?
    var user_phoneNum: String?
    var user_birthday: String?
}
