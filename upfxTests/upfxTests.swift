//
//  upfxTests.swift
//  upfxTests
//
//  Created by Wenzhong Zhang on 2024-11-21.
//

import Testing
import Foundation
import OSLog
@testable import upfx

struct upfxTests {

    @Test func regexSimplify() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        guard let bundle: Bundle = .allBundles.first(where: {$0.bundleURL.pathComponents.last ?? "" == "upfxTests.xctest" }) else { return }
        guard let filePath = bundle.path(forResource: "20241120", ofType: "json") else { return }
        do {
            let data : Data = try .init(contentsOf: .init(fileURLWithPath: filePath))
            var text = String(decoding: data, as: UTF8.self)
            text.replace(/exchangeRateJson/, with: "rates")
            text.replace(/curDate/, with: "d")
            text.replace(/transCur/, with: "tr")
            text.replace(/rateData/, with: "r")
            text.replace(/baseCur/, with: "ba")
            print(text)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    @Test func retreiveToday() async throws {
        let nController = NetworkController.shared
        let date = Date()
        if let rates = nController.ratesController.searchRatesLocallyFor(date: date) {
            print("Found rates, total pairs: \(rates.exchangeRateJson.count)")
            return
        } else {
            try await nController.processJSON(for: date)
        }
        #expect(nController.ratesController.searchRatesLocallyFor(date: date) != nil)
    }
    @Test("Testing CNY HKD pairs")
    func retreiveCNYHKDRate() async throws {
        let date = Date()
        let nController = NetworkController.shared
        try await nController.processJSON(for: date)
        var result: Double = -1.0
        if let rates = nController.ratesController.searchRatesLocallyFor(date: date) {
            if let rate = rates.exchangeRateJson.first(where: {$0.baseCur == "CNY" && $0.transCur == "HKD"}) {
                result = 1000.0 * rate.rateData
            }
        }
        #expect(result > 0, "Result must be greater than 0")
        print("Testing 1000 HKD to CNY---\(result)")
    }
    @Test func deleteToday() async throws {
        let shared = RatesController.shared
        _ = shared.removeRatesOn(date: .init())
        #expect(shared.searchRatesLocallyFor(date: .init()) == nil)
    }
}
