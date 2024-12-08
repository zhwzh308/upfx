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
        let date = Date()
        let nController = NetworkController()
        try await nController.processJSON(for: date)
        #expect(nController.ratesFor(date: date) != nil)
    }
}
