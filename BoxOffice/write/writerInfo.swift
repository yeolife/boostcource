//
//  writerInfo.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/16.
//

import Foundation

struct reviewWrite: Codable {
    let rating: Double
    let timestamp: Double
    let writer: String
    let movie_id: String
    let contents: String
}
