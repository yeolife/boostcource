//
//  singletoneInfo.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/01.
//

import Foundation
import UIKit


class singletone {
    static let shared: singletone = singletone()
    
    lazy var replyNickname: String? = nil
    
    private init() {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemIndigo
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    // 네비게이션 바 레이아웃
    private let appearance = UINavigationBarAppearance()
    
    func setupLayout(for vc: UIViewController) {
        vc.navigationItem.standardAppearance = appearance
        vc.navigationItem.scrollEdgeAppearance = appearance
    }
}
