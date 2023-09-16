//
//  StarRatingUISlider.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/16.
//

import UIKit

class StarRatingUISlider: UISlider {
    
    // 슬라이더바 터치로 점수 반영
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x/width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        
        return true
    }
}
