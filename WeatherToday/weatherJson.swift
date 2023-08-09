//
//  weatherJson.swift
//  WeatherToday
//
//  Created by yeolife on 2023/08/08.
//

import Foundation

// MARK: - 나라
struct country: Codable{
    let korean_name: String
    let asset_name: String
}

// MARK: - 도시
struct city: Codable {
    let city_name: String
    let state: Int
    let celsius: Float
    var celsiusAndFahrenheit: String {
        var fahrenheit: Float
        fahrenheit = (self.celsius * 1.8) + 32
        return "섭씨 \(self.celsius)도 / 화씨 \(String(format: "%.1f" ,fahrenheit))도"
    }
    let rainfall_probability: Int
    var rainfall_probability_string: String {
        return "강수확률 \(self.rainfall_probability)%"
    }
}
