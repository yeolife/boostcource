//
//  movieMoreInfo.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/12.
//

import Foundation

// json 데이터의 형식
struct movieMoreAPI: Codable, Hashable {
    struct replyAPI: Codable {
        let comments: [moreReplyFormat]
    }
    
    struct moreInfoFormat: Codable, Hashable {
        var audience: Int
        var grade: Int
        var actor: String
        var duration: Int
        var reservation_grade: Int
        var title: String
        var reservation_rate: Double
        var user_rating: Double
        var date: String
        var director: String
        var id: String
        var image: String
        var synopsis: String
        var genre: String
        
        static func == (lhs: moreInfoFormat, rhs: moreInfoFormat) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct moreContentFormat: Hashable {
        var synopsis: String
        
        init(synopsis: String) {
            self.synopsis = ""
        }
    }
    
    struct moreDirectorFormat: Hashable {
        var director: String
        var actor: String
        
        init(director: String, actor: String) {
            self.director = ""
            self.actor = ""
        }
    }
    
    struct moreReplyFormat: Codable, Hashable {
        var rating: Double
        var timestamp: Double
        var writer: String
        var movie_id: String
        var contents: String
        var id: String
        
        static func == (lhs: moreReplyFormat, rhs: moreReplyFormat) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
