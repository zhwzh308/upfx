//
//  NetworkController.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-11-21.
//

import Foundation

struct NetworkControllerError: LocalizedError {
    let description: String
    init(_ description: String) {
        self.description = description
    }
    var errorDescription: String? {
        description
    }
}

class NetworkController {
    static let shared = NetworkController()
    private var dateFormatter: DateFormatter {
        Utility.shared.dateFormatter
    }
    var ratesController: RatesController {
        RatesController.shared
    }
    /// This is called when data is neither found in-memory nor on-disk
    /// - Throws: If the URL isn’t valid, this method throws the `NetworkControllerError` error.
    private func fetchAndSaveJSON(for date: Date) async throws {
        let parameters = DayRatesParameters(date: date)
        guard let url = URL(string: parameters.urlString) else {
            throw NetworkControllerError("Invalid URL")
        }
        let result = try await URLSession.shared.data(from: url)
        _ = DayRatesController(parameters: parameters, data: result.0)
    }
    func processJSON(for date: Date, retryCount: Int = 0, maxRetries: Int = 3) async throws {
        // Step 1: Check if the file exists locally
        if let localData = ratesController.searchRatesLocallyFor(date: date) {
            print("Process found data locally.")
        } else {
            // Step 2: If not found locally, try downloading it
            guard retryCount < maxRetries else {
                throw NetworkControllerError("Maximum retry attempts reached. Rates not available.")
            }
            print("Rates not found locally. Attempting to download. Retry: \(retryCount + 1)")
            try await fetchAndSaveJSON(for: date)
            try await processJSON(for: date, retryCount: retryCount + 1, maxRetries: maxRetries)
        }
    }
}
