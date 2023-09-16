//
//  dataResponse.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/16.
//

import Foundation

let DidReceiveWritingNotification: Notification.Name = Notification.Name("didReceiveWriting")
let DidReceiveErrorNotification: Notification.Name = Notification.Name("didReceiveError")

func dataResponse(writingData: reviewWrite, urlAddress: String) {
    guard let url: URL = URL(string: urlAddress) else { fatalError("URL Error") }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let jsonData = try JSONEncoder().encode(writingData)
        request.httpBody = jsonData
    } catch {
        print(error.localizedDescription)
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    
    let dataTask: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let data = data else { return }
        
        // 서버의 응답을 처리합니다.
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(json)
                
                NotificationCenter.default.post(name: DidReceiveWritingNotification,
                                                object: nil)
            }
        } catch {
            NotificationCenter.default.post(name: DidReceiveErrorNotification,
                                            object: nil)
            
            print(error.localizedDescription)
        }
    }
    
    dataTask.resume()
}
