//
//  Untitled.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-11-21.
//

struct ExchangeRate: Codable {
    let transCur: String
    let baseCur: String
    let rateData: Double
}

struct ExchangeRateJson: Codable {
    let exchangeRateJson: [ExchangeRate]
}
