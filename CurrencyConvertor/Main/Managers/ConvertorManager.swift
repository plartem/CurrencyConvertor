//
//  ConvertorManager.swift
//  CurrencyConvertor
//
//

import Foundation
import UIKit

protocol ConvertorManagerDelegate: AnyObject {
    func convertorManager(
        convertedCurrenciesData: [ConvertorManager.ConvertedCurrencyData]
    )
}

class ConvertorManager: NSObject {
    // MARK: - Properties

    weak var delegate: ConvertorManagerDelegate?

    var model: Model? {
        didSet {
            updateDisplayedCurrenciesData()
        }
    }
    var exchangeRates: [ExchangeRate]? {
        didSet {
            updateDisplayedCurrenciesData()
        }
    }

    private var mainCurrency: String?
    private var mainCurrencyValue: Double = 0.0

    // MARK: - Methods

    func addDisplayCurrency(code: String) {
        if model?.displayedCurrencies.contains(code) == false {
            model?.displayedCurrencies.append(code)
        }
    }

    func currencyValueChanged(value: Double?, at index: Int) {
        mainCurrency = model?.displayedCurrencies[safe: index]
        mainCurrencyValue = value ?? 0.0
        updateDisplayedCurrenciesData()
    }

    func removeDisplayedCurrency(forRowAt index: Int) {
        if model?.displayedCurrencies.indices.contains(index) == true {
            model?.displayedCurrencies.remove(at: index)
        }
    }

    private func updateDisplayedCurrenciesData() {
        guard let data = model else {
            delegate?.convertorManager(convertedCurrenciesData: [])
            return
        }
        guard let rates = exchangeRates,
              let mainCurrencyRate = rates.first(where: { $0.currencyCode == mainCurrency }) else {
            delegate?.convertorManager(
                convertedCurrenciesData: data.displayedCurrencies.map {
                    ConvertedCurrencyData(
                        currencyCode: $0,
                        currencyValue: "",
                        isMainCurrency: $0 == mainCurrency
                    )
                }
            )
            return
        }
        let convertedMainCurrencyValue = mainCurrencyValue
            * mainCurrencyRate.rate(exchangeType: data.currentExchangeType)
        let convertedCurrenciesData = data.displayedCurrencies
            .compactMap { currency in rates.first(where: { $0.currencyCode == currency }) }
            .map { currency -> ConvertedCurrencyData in
                let currencyRate = currency.rate(exchangeType: data.currentExchangeType)
                let currencyValue = convertedMainCurrencyValue / currencyRate
                let currencyStringValue = currencyValue.isZero || currencyValue.isNaN
                    ? ""
                    : String(format: "%.2f", currencyValue)
                return ConvertedCurrencyData(
                    currencyCode: currency.currencyCode,
                    currencyValue: currencyStringValue,
                    isMainCurrency: currency.currencyCode == mainCurrency
                )
            }
        delegate?.convertorManager(convertedCurrenciesData: convertedCurrenciesData)
    }
}

// MARK: - Models

extension ConvertorManager {
    struct Model: Equatable {
        var currentExchangeType: MainViewController.ExchangeType
        var displayedCurrencies: [String]
    }

    struct ExchangeRate: Equatable {
        let currencyCode: String
        let buy: Double
        let sell: Double

        func rate(exchangeType: MainViewController.ExchangeType) -> Double {
            switch exchangeType {
            case .buy: return buy
            case .sell: return sell
            }
        }
    }

    struct ConvertedCurrencyData {
        let currencyCode: String
        let currencyValue: String
        let isMainCurrency: Bool
    }
}

// MARK: - Constants

extension ConvertorManager {
    private enum Constants {}
}
