//
//  Utility.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-12-07.
//

import Foundation

struct DayRatesParameters {
    let date: Date
    let fileName: String
    let dateString: String
    let urlString : String
    // var jsonData: ExchangeRateJson?
    init(date: Date) {
        self.date = date
        dateString = Utility.shared.dateFormatter.string(from: date)
        fileName = dateString + ".json"
        urlString = "https://www.unionpayintl.com/upload/jfimg/\(fileName)"
    }
    init() {
        self.init(date: .init())
    }
}

class Utility {
    private lazy var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        // UnionPay assumes Beijing/HK timezone
        dateFormatter.timeZone = .init(abbreviation: "HKT")
        return dateFormatter
    }()
    static let shared = Utility()
    var dateFormatter: DateFormatter {
        return _dateFormatter
    }
}
