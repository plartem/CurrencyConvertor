//
//  AddCurrencyViewController.swift
//  CurrencyConvertor
//
//

import Foundation
import SnapKit
import UIKit

protocol AddCurrencyViewControllerDelegate: AnyObject {
    func addCurrencyViewController(
        _ addCurrencyViewController: AddCurrencyViewController,
        didSelectCurrency currencyCode: String
    )
}

class AddCurrencyViewController: UIViewController {
    private enum Convertor {
        static func convert(currencyCodes: [String]) -> [CurrenciesTableViewManager.Model.CurrencyData] {
            let locale = Locale(identifier: GlobalConstants.localeIdentifier)
            return currencyCodes.map { code in
                let displayName = String(
                    format: Constants.displayNameFormat,
                    code,
                    locale.localizedString(forCurrencyCode: code) ?? ""
                )
                return CurrenciesTableViewManager.Model.CurrencyData(
                    code: code,
                    displayName: displayName
                )
            }
        }
    }

    // MARK: - Properties

    weak var delegate: AddCurrencyViewControllerDelegate?

    private let currenciesTableViewManager = CurrenciesTableViewManager()
    private let data: Data

    // MARK: UI

    private let backButton: UIButton = {
        let button = UIButton(configuration: Constants.BackButton.config)
        return button
    }()
    private let currenciesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)

        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = Constants.searchControllerPlaceholder
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.barTintColor = .systemGroupedBackground

        return searchController
    }()

    // MARK: - Initialization

    init(data: Data) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = buildView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultConfiguration()
    }

    // MARK: Configurations

    private func buildView() -> UIView {
        let contentView = UIView()

        // Content Stack View
        contentView.addSubview(currenciesTableView)
        currenciesTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return contentView
    }

    private func defaultConfiguration() {
        title = Constants.title
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        currenciesTableViewManager.searchController = searchController
        currenciesTableViewManager.tableView = currenciesTableView
        currenciesTableViewManager.delegate = self
        currenciesTableViewManager.model = .init(
            popularCurrencies: Convertor.convert(currencyCodes: data.popularCurrencies),
            currencies: Convertor.convert(currencyCodes: data.currencies)
        )
    }

    func dismiss() {
        dismiss(animated: true)
    }

    @objc private func backButtonTapped() {
        dismiss()
    }
}

// MARK: - CurrenciesTableViewManagerDelegate

extension AddCurrencyViewController: CurrenciesTableViewManagerDelegate {
    func currenciesTableViewManager(_: CurrenciesTableViewManager, didSelectCurrency currencyCode: String) {
        delegate?.addCurrencyViewController(self, didSelectCurrency: currencyCode)
    }
}

// MARK: - Data

extension AddCurrencyViewController {
    struct Data {
        let popularCurrencies: [String]
        let currencies: [String]
    }
}

// MARK: - Constants

extension AddCurrencyViewController {
    private enum Constants {
        static let title = "Currency"
        static let displayNameFormat = "%@ - %@"
        static let searchControllerPlaceholder = "Search currency"
        enum BackButton {
            static let config: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.borderless()
                buttonConfig.title = "Converter"
                buttonConfig.image = UIImage(systemName: "chevron.backward")
                return buttonConfig
            }()
        }
    }
}
