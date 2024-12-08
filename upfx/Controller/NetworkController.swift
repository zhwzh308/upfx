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
    private lazy var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()
    private lazy var _fileManager: FileManager = FileManager.default
    private lazy var _megaDictionary: [String : ExchangeRateJson] = [:]
    private func fetchAndSaveJSON(for date: String) async throws {
        let urlString = "https://www.unionpayintl.com/upload/jfimg/\(date).json"
        guard let url = URL(string: urlString) else {
            throw NetworkControllerError("Invalid URL")
        }
        let result = try await URLSession.shared.data(from: url)
        let data = result.0
        try self.saveDataToFile(data: data, fileName: "\(date).json")
    }
    // Deserialize the data
    private func deserializeAndUseData(_ data: Data) -> ExchangeRateJson? {
        
        do {
            return try JSONDecoder().decode(ExchangeRateJson.self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    // Read local file
    private func readLocalJSON(fileName: String) throws -> Data {
        guard let documentsDirectory = _fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NetworkControllerError("Unable to locate documents directory")
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return try Data(contentsOf: fileURL)
    }
    // Save file locally
    private func saveDataToFile(data: Data, fileName: String) throws {
        guard let documentsDirectory = _fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NetworkControllerError("Unable to locate documents directory")
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            print("Rates saved successfully to: \(fileURL.path)")
        } catch {
            throw NetworkControllerError("Error saving rates: \(error)")
        }
    }
    func processJSON(for date: Date, retryCount: Int = 0, maxRetries: Int = 3) async throws {
        let formattedDate = _dateFormatter.string(from: date)
        let fileName = "\(formattedDate).json"
        
        // Step 1: Check if the file exists locally
        do {
            let localData = try readLocalJSON(fileName: fileName)
            print("Rates found locally: \(fileName)")
            // Deserialize and process the JSON
            if let decodedData = deserializeAndUseData(localData) {
                _megaDictionary[formattedDate] = decodedData
            }
        } catch {
            // Step 2: If not found locally, try downloading it
            guard retryCount < maxRetries else {
                throw NetworkControllerError("Maximum retry attempts reached. Rates not available.")
            }
            print("Rates not found locally. Attempting to download. Retry: \(retryCount + 1)")
            try await fetchAndSaveJSON(for: formattedDate)
            try await processJSON(for: date, retryCount: retryCount + 1, maxRetries: maxRetries)
        }
    }
    func ratesFor(date: Date) -> ExchangeRateJson? {
        return _megaDictionary[_dateFormatter.string(from: date)]
    }
}
