//
//  singleton.swift
//  MyAlbum
//
//  Created by yeolife on 2023/08/16.
//

import UIKit
import Foundation
import Photos

// 싱글톤
class photoInfo{
    static let shared: photoInfo = photoInfo()
    
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    var options = PHImageRequestOptions()
    let screenWidth: CGFloat = { // 절대적인 화면 너비값 (회전 상태에서 앱 실행시 너비와 높이가 바뀌는 것을 방지)
        let screenSize = UIScreen.main.bounds.size
        let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let interfaceOrientation = windowScene.interfaceOrientation

        if interfaceOrientation.isPortrait {
            return screenSize.width
        }
        else {
            return screenSize.height
        }
    }()
}
