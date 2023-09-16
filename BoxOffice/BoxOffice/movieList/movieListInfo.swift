//
//  movieListInfo.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/03.
//

import Foundation
import UIKit

struct movieListAPI: Codable {
    let order_type: Int
    
    let movies: [movieListFormat]
}


struct movieListFormat: Codable, Hashable {
    let grade:Int
    let thumb: String
    let reservation_grade: Int
    let title: String
    let reservation_rate: Double
    let user_rating: Double
    let date: String
    let id: String
    
    var movieEvaluationText: String {
        return "평점: \(self.user_rating) 예매순위: \(self.reservation_grade) 예매율: \(self.reservation_rate)"
    }
    
    var movieDateText: String {
        return "개봉일: \(self.date)"
    }
    
    static func == (lhs: movieListFormat, rhs: movieListFormat) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


let DidChangeMovieListNotification: Notification.Name = Notification.Name("didChangeMovies")

// 테이블 뷰와 컬렉션뷰가 '참조'하고 변경하므로 class 타입으로 전역변수 생성
final class movieListData {
    static let shared: movieListData = movieListData()
    
    var movieListItem: [movieListFormat] = []
    
    // 네비게이션 바 제목
    var currentSort: Int = 0
    
    func setMovieListTitle() -> String {
        switch self.currentSort {
        case 0:
            return "예매율"
        case 1:
            return "평점"
        case 2:
            return "개봉일"
        default:
            return ""
        }
    }
    
    func setMovieListSort(getSortNum: Int) {
        // 현재 상태와 같으면 리턴
        if(self.currentSort == getSortNum) {
            return
        }
        
        // 네비게이션 바 제목 변경
        self.currentSort = getSortNum

        switch getSortNum {
        case 0:
            self.movieListItem.sort { $0.reservation_grade < $1.reservation_grade }
        case 1:
            self.movieListItem.sort { $0.user_rating > $1.user_rating }
        case 2:
            self.movieListItem.sort { $0.date > $1.date }
        default:
            return
        }
    }
}
