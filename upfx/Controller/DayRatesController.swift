//
//  RateController.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-12-08.
//

import Foundation

struct DayRatesControllerError: LocalizedError {
    let description: String
    init(_ description: String) {
        self.description = description
    }
    var errorDescription: String? {
        description
    }
}

/**
 */

class DayRatesController {
    let parameters: DayRatesParameters
    var jsonData: ExchangeRateJson?
    private lazy var _fileManager: FileManager = FileManager.default
    init(parameters: DayRatesParameters, data: Data? = nil) {
        self.parameters = parameters
        if let d = data {
            // Scenario 1: caller supplied data, want to save data to file
            do {
                guard let documentsDirectory = _fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw DayRatesControllerError("Unable to locate documents directory")
                }
                let fileURL = documentsDirectory.appendingPathComponent(parameters.fileName)
                do {
                    try d.write(to: fileURL)
                    print("Rates saved successfully to: \(fileURL.path)")
                    if let result = try deserializeAndUseData(d) {
                        print("Rates deserialized successfully, total rates \(result.exchangeRateJson.count)")
                        jsonData = result
                    } else {
#if DEBUG
                        throw DayRatesControllerError("Error serializing data to ExchangeRateJson")
#else
                        print("Error serializing data, need to do something in debug")
#endif
                    }
                } catch {
                    throw DayRatesControllerError("Error saving rates: \(error)")
                }
            } catch {
                print(error)
            }
        } else {
            // Scenario 2: want to read from local json file.
            do {
                if let rates = try readLocalJSONFile() {
                    print("Not found in-memory, found in file. Saving in-memory")
                    jsonData = rates
                }
            } catch {
                print("Not found in memory, file store also failed.")
            }
        }
    }
    convenience init() {
        self.init(parameters: DayRatesParameters(date: .init()))
    }
    convenience init(date: Date, data: Data? = nil) {
        self.init(parameters: DayRatesParameters(date: date), data: data)
    }
    /// Deserialize the data
    /// - Parameters:
    ///   - data: Data to deserialize, expecting an `application/json` type of ExchangeRateJson
    /// - Returns: Optional result.
    /// - Throws: If the data isn’t valid JSON, this method throws the `DecodingError.dataCorrupted(_:)` error.
    private func deserializeAndUseData(_ data: Data) throws -> ExchangeRateJson? {
        return try JSONDecoder().decode(ExchangeRateJson.self, from: data)
    }
    /// Read local file
    /// - Returns: Optional result.
    /// - Throws: If document folder cannot be found, it throws `DayRatesControllerError` error.
    private func readLocalJSONFile() throws -> ExchangeRateJson? {
        guard let documentsDirectory = _fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DayRatesControllerError("Unable to locate documents directory")
        }
        let fileURL = documentsDirectory.appendingPathComponent(parameters.fileName)
        let data =  try Data(contentsOf: fileURL)
        return try deserializeAndUseData(data)
    }
}
