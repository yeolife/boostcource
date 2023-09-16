//
//  dataRequest.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/02.
//

import Foundation

let DidReceiveMovieDataNotification: Notification.Name = Notification.Name("didReceiveMovies")
let DidReceiveMoreDataNotification: Notification.Name = Notification.Name("didReceiveMoreData")
let DidReceiveMoreReplyNotification: Notification.Name = Notification.Name("didReceiveMoreReply")


// 영화목록 데이터 요청
func dataRequest(getURL: String) {
    guard let url: URL = URL(string: getURL) else { fatalError("error") }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { data, response, error in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let data = data else { return }
                
        do {
            let apiResponse: movieListAPI = try JSONDecoder().decode(movieListAPI.self, from: data)
            movieListData.shared.movieListItem = apiResponse.movies
            
            NotificationCenter.default.post(name: DidReceiveMovieDataNotification,
                                            object: nil,
                                            userInfo: nil)
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    dataTask.resume()
}

// 영화상세정보 데이터 요청
func dataRequest(getURL: String, ID: String, type: String) {
    guard let url: URL = URL(string: getURL + ID) else { fatalError("error") }

    let session: URLSession = URLSession(configuration: .default)

    let dataTask: URLSessionDataTask = session.dataTask(with: url) { data, response, error in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let data = data else { return }
        do {
            switch type {
            case "info": // 상세정보
                let apiResponse: movieMoreAPI.moreInfoFormat = try JSONDecoder().decode(movieMoreAPI.moreInfoFormat.self, from: data)
                
                NotificationCenter.default.post(name: DidReceiveMoreDataNotification,
                                                object: nil,
                                                userInfo: [type: apiResponse])
            case "reply": // 댓글
                let apiResponse: movieMoreAPI.replyAPI = try JSONDecoder().decode(movieMoreAPI.replyAPI.self, from: data)

                NotificationCenter.default.post(name: DidReceiveMoreReplyNotification,
                                                object: nil,
                                                userInfo: [type: apiResponse.comments])
            default:
                return
            }
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    dataTask.resume()
}
