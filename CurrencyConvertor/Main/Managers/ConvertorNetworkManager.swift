//
//  ConvertorNetworkManager.swift
//  CurrencyConvertor
//
//

import Foundation
import RxCocoa
import RxSwift

class ConvertorNetworkManager: NSObject {
    // MARK: - Properties

    private let disposeBag = DisposeBag()

    // MARK: - Methods

    func fetchCurrentExchangeRates(completionHandler: @escaping (Result<ExchangeRatesModel, Error>) -> Void) {
        let defaultRatesSequence = fetchExchangeRatesFrom(url: Constants.defaultRatesApiURL)
        let extraRatesSequence = fetchExchangeRatesFrom(url: Constants.extraRatesApiURL)
        let finalSequence = Observable.zip(
            defaultRatesSequence,
            extraRatesSequence
        ) { defaultRates, extraRates -> [ExchangeRatesModel.ExchangeRate] in
            defaultRates + extraRates
        }

        finalSequence
            .subscribe(
                onNext: { rates in
                    var finalRates = rates.filter { $0.baseCurrencyCode == Constants.defaultBaseCurrency }
                    finalRates.insert(
                        .init(
                            currencyCode: Constants.defaultBaseCurrency,
                            baseCurrencyCode: Constants.defaultBaseCurrency,
                            buyRate: "1.0",
                            saleRate: "1.0"
                        ),
                        at: 0
                    )
                    completionHandler(
                        .success(
                            ExchangeRatesModel(
                                exchangeRates: finalRates,
                                updateTime: Date()
                            )
                        )
                    )
                },
                onError: { error in
                    completionHandler(.failure(error))
                },
                onCompleted: {},
                onDisposed: {}
            )
            .disposed(by: disposeBag)
    }

    private func fetchExchangeRatesFrom(url: String) -> Observable<[ExchangeRatesModel.ExchangeRate]> {
        return Observable.create { obs in
            guard let url = URL(string: url) else {
                obs.onError(NetworkManagerError.urlError)
                return Disposables.create()
            }
            let request = URLRequest(url: url)
            return URLSession.shared.rx.response(request: request).subscribe(
                onNext: { response in
                    let decoder = JSONDecoder()
                    do {
                        let model = try decoder.decode([ExchangeRatesModel.ExchangeRate].self, from: response.data)
                        obs.onNext(model)
                    } catch {
                        obs.onError(NetworkManagerError.decodingError)
                    }
                },
                onError: { error in
                    obs.onError(error)
                }
            )
        }
    }
}

// MARK: - Models

extension ConvertorNetworkManager {
    enum NetworkManagerError: Error {
        case urlError
        case decodingError
        case responseDataError
    }
}

// MARK: - Constants

extension ConvertorNetworkManager {
    private enum Constants {
        static let defaultBaseCurrency = "UAH"
        static let defaultRatesApiURL = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=11"
        static let extraRatesApiURL = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=12"
    }
}
