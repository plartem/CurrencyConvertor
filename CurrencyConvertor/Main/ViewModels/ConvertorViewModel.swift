//
//  ConvertorViewModel.swift
//  CurrencyConvertor
//
//

import CoreLocation
import Foundation
import RxCocoa
import RxSwift

class ConvertorViewModel: NSObject {
    // MARK: - Properties

    let model = BehaviorRelay<ExchangeRatesModel?>(value: nil)
    let convertedCurrencies = BehaviorRelay<[ConvertorManager.ConvertedCurrencyData]?>(value: nil)
    let showAddCurrencyScreen = BehaviorRelay<AddCurrencyViewController.Data?>(value: nil)

    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    private let convertorManager = ConvertorManager()
    private let convertorNetworkManager = ConvertorNetworkManager()
    private let userDefaults = UserDefaults.standard
    private let disposeBag = DisposeBag()

    private var popularCurrencies: [String] = Constants.defaultExchangeCurrencies

    private var exchangeRateUpdateTimer: Timer?

    // MARK: - Initialization

    override init() {
        super.init()
        defaultConfiguration()
    }

    deinit {
        exchangeRateUpdateTimer?.invalidate()
    }

    // MARK: - Configuration

    private func defaultConfiguration() {
        loadModel()
        initConvertorManager()
        initExchangeUpdateRateTimer()
        subscribe()
        configureLocationManager()
    }

    // MARK: - Actions

    func onControllerDefaultConfiguration(exchangeType: MainViewController.ExchangeType) {
        updateCurrencyExchangeType(exchangeType)
    }

    func onCurrentCountryCurrencyChanged(code: String) {
        addPopularCurrency(code: code)
    }

    func onSegmedntedControlValueChanged(_ value: MainViewController.ExchangeType) {
        updateCurrencyExchangeType(value)
    }

    func onCurrencySelect(_ currencyCode: String) {
        addDisplayCurrency(code: currencyCode)
    }

    func onCurrencyTextFieldValueChanged(_ value: Double?, forRowAt index: Int) {
        updateCurrencyValue(value, forRowAt: index)
    }

    func onRemoveCurrencyButtonTapped(forRowAt index: Int) {
        removeDisplayedCurrency(forRowAt: index)
    }

    func onAddButtonTapped() {
        updateShowAddCurrencyScreenData()
    }

    // MARK: - Methods

    private func initConvertorManager() {
        convertorManager.model = .init(
            currentExchangeType: .sell,
            displayedCurrencies: popularCurrencies
        )
        convertorManager.delegate = self
    }

    private func initExchangeUpdateRateTimer() {
        exchangeRateUpdateTimer = Timer.scheduledTimer(
            timeInterval: Constants.exchangeRateUpdateTimerInterval,
            target: self,
            selector: #selector(exchangeRateUpdateTimerFired),
            userInfo: nil,
            repeats: true
        )
        exchangeRateUpdateTimer?.fire()
    }

    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        updateCurrentLocation()
    }

    private func updateCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    private func updateConvertorManagerExchangeRates(_ data: ExchangeRatesModel) {
        convertorManager.exchangeRates = data.exchangeRates.map {
            .init(
                currencyCode: $0.currencyCode,
                buy: Double($0.buyRate) ?? 0.0,
                sell: Double($0.saleRate) ?? 0.0
            )
        }
    }

    private func saveModel() {
        let encoder = JSONEncoder()
        if let data = model.value,
           let encoded = try? encoder.encode(data) {
            userDefaults.set(encoded, forKey: Constants.userDefaultsKey)
        }
    }

    private func loadModel() {
        let decoder = JSONDecoder()
        if let data = userDefaults.object(forKey: Constants.userDefaultsKey) as? Data,
           let exchangeRates = try? decoder.decode(ExchangeRatesModel.self, from: data) {
            model.accept(exchangeRates)
        } else {
            model.accept(nil)
        }
    }

    private func timerUpdateExchangeRates() {
        fetchExchangeRates()
    }

    private func fetchExchangeRates() {
        convertorNetworkManager.fetchCurrentExchangeRates { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.model.accept(data)
                self.saveModel()
            case .failure:
                self.model.accept(nil)
            }
        }
    }

    private func updateCurrencyExchangeType(_ type: MainViewController.ExchangeType) {
        convertorManager.model?.currentExchangeType = type
    }

    private func addPopularCurrency(code: String) {
        if !popularCurrencies.contains(code) {
            popularCurrencies.append(code)
            convertorManager.addDisplayCurrency(code: code)
        }
    }

    private func addDisplayCurrency(code: String) {
        convertorManager.addDisplayCurrency(code: code)
    }

    private func removeDisplayedCurrency(forRowAt index: Int) {
        convertorManager.removeDisplayedCurrency(forRowAt: index)
    }

    private func updateCurrencyValue(_ value: Double?, forRowAt index: Int) {
        convertorManager.currencyValueChanged(value: value, at: index)
    }

    private func updateShowAddCurrencyScreenData() {
        func removeDisplayedCurrencies(_ currencies: [String]) -> [String] {
            currencies.filter { currency in
                !(convertorManager.model?.displayedCurrencies.contains(
                    where: { $0 == currency }
                ) ?? false)
            }
        }
        let currencies = model.value?.exchangeRates.map { $0.currencyCode } ?? []
        showAddCurrencyScreen.accept(
            AddCurrencyViewController.Data(
                popularCurrencies: removeDisplayedCurrencies(
                    popularCurrencies
                ),
                currencies: removeDisplayedCurrencies(currencies)
            )
        )
    }

    // MARK: - Timer action

    @objc private func exchangeRateUpdateTimerFired() {
        if let data = model.value {
            let lastUpdateHour = Calendar.current.component(.hour, from: data.updateTime)
            let currentDate = Date()
            let currentHour = Calendar.current.component(.hour, from: currentDate)
            if currentDate > data.updateTime, lastUpdateHour != currentHour {
                timerUpdateExchangeRates()
            }
        } else {
            timerUpdateExchangeRates()
        }
    }
}

// MARK: - RX

extension ConvertorViewModel {
    private func subscribe() {
        model
            .subscribe(onNext: { [weak self] model in
                guard let data = model else { return }
                self?.updateConvertorManagerExchangeRates(data)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: ConvertorManagerDelegate

extension ConvertorViewModel: ConvertorManagerDelegate {
    func convertorManager(convertedCurrenciesData: [ConvertorManager.ConvertedCurrencyData]) {
        convertedCurrencies.accept(convertedCurrenciesData)
    }
}

// MARK: CLLocationManagerDelegate

extension ConvertorViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        guard let location = manager.location else { return }
        geoCoder.reverseGeocodeLocation(
            location,
            completionHandler: { [weak self] placemarks, _ in
                if let placemark = placemarks?.first,
                   let countryCode = placemark.isoCountryCode,
                   let currencyCode = Locale(
                       identifier: GlobalConstants.localeLanguageCode + "_" + countryCode
                   ).currencyCode {
                    self?.onCurrentCountryCurrencyChanged(code: currencyCode)
                }
            }
        )
    }
}

// MARK: - Constants

extension ConvertorViewModel {
    private enum Constants {
        static let userDefaultsKey = "ExchangeRatesModel"
        static let exchangeRateUpdateTimerInterval: TimeInterval = 60.0
        static let defaultExchangeCurrencies = ["USD", "EUR"]
    }
}
