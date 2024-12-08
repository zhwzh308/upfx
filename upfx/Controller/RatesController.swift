//
//  RatesController.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-12-07.
//

import Foundation

struct RatesControllerError: LocalizedError {
    let description: String
    init(_ description: String) {
        self.description = description
    }
    var errorDescription: String? {
        description
    }
}

class RatesController {
    private lazy var _megaDictionary: [String : ExchangeRateJson] = [:]
    static let shared = RatesController()
    /// Perform search on local resources
    func searchRatesLocallyFor(date: Date) -> ExchangeRateJson? {
        let parameters = DayRatesParameters(date: date)
        return searchRatesLocallyWith(parameters)
    }
    func removeRatesOn(date: Date) -> Bool {
        let parameters = DayRatesParameters(date: date)
        if let value = _megaDictionary.removeValue(forKey: parameters.dateString) {
            print("Successfully removed in-memory value, removing \(value.exchangeRateJson.count) records. Proceeding to file removal - pending")
            return true
        }
        return false
    }
    func saveInMem(rates: ExchangeRateJson, for key: String) {
        _megaDictionary[key] = rates
    }
    /// Try in-memory or on-disk. Note: this function only tries locally
    private func searchRatesLocallyWith(_ parameters: DayRatesParameters) -> ExchangeRateJson? {
        // Path 1: in-mem
        if let rates = _megaDictionary[parameters.dateString] {
            return rates
        }
        // Path 2: Let DayRatesController handle things
        let dayRateController = DayRatesController(parameters: parameters)
        if let rates = dayRateController.jsonData {
            // Found on-disk, we are still responsible for saving the results to memory.
            saveInMem(rates: rates, for: parameters.dateString)
            return rates
        }
        // Neither found in-mem nor on-disk.
        return nil
    }
}
