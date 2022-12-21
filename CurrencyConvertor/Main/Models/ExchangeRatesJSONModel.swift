//
//  ExchangeRatesJSONModel.swift
//  CurrencyConvertor
//
//

import Foundation

struct ExchangeRatesModel: Codable {
    // MARK: - ExchangeRate

    struct ExchangeRate: Codable {
        let currencyCode: String
        let baseCurrencyCode: String
        let buyRate: String
        let saleRate: String

        enum CodingKeys: String, CodingKey {
            case currencyCode = "ccy"
            case baseCurrencyCode = "base_ccy"
            case buyRate = "buy"
            case saleRate = "sale"
        }
    }

    let exchangeRates: [ExchangeRate]
    let updateTime: Date
}
