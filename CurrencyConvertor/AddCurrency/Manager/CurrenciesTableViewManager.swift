//
//  CurrenciesTableViewManager.swift
//  CurrencyConvertor
//
//

import Foundation
import SnapKit

protocol CurrenciesTableViewManagerDelegate: AnyObject {
    func currenciesTableViewManager(
        _ currenciesTableViewManager: CurrenciesTableViewManager,
        didSelectCurrency currencyCode: String
    )
}

class CurrenciesTableViewManager: NSObject {
    // MARK: - Properties

    weak var delegate: CurrenciesTableViewManagerDelegate?

    weak var searchController: UISearchController? {
        didSet {
            searchController?.searchResultsUpdater = self
            tableView?.tableHeaderView = searchController?.searchBar
        }
    }

    weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self

            tableView?.tableHeaderView = searchController?.searchBar

            tableView?.register(
                UITableViewHeaderFooterView.self,
                forHeaderFooterViewReuseIdentifier: kDefaultTableViewHeaderFooterIdentifier
            )
            tableView?.register(
                UITableViewCell.self,
                forCellReuseIdentifier: kDefaultTableViewCellIdentifier
            )
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }

    var model: Model? {
        didSet {
            reloadTableViewData(oldValue: oldValue)
        }
    }

    private var filteredCurrenciesDictionary: [String: [Model.CurrencyData]] = [:]
    private var currenciesDictionary: [String: [Model.CurrencyData]] = [:]
    private var currentCurrenciesDataSource: [String: [Model.CurrencyData]] {
        if searchController?.isActive == true {
            return filteredCurrenciesDictionary
        } else {
            return currenciesDictionary
        }
    }

    private var filteredSectionTitles: [String] = []
    private var sectionTitles: [String] = []
    private var currentSectionTitles: [String] {
        if searchController?.isActive == true {
            return filteredSectionTitles
        } else {
            return sectionTitles
        }
    }

    // MARK: - Methods

    private func reloadTableViewData(oldValue _: Model?) {
        guard let data = model else {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
            return
        }
        for currency in data.currencies {
            let key = String(currency.code.prefix(1))
            if var values = currenciesDictionary[key] {
                values.append(currency)
                currenciesDictionary[key] = values
            } else {
                currenciesDictionary[key] = [currency]
            }
        }

        sectionTitles = [String](currenciesDictionary.keys)
        sectionTitles = sectionTitles.sorted { $0 < $1 }

        if !data.popularCurrencies.isEmpty {
            currenciesDictionary[Constants.popularSectionTitle] = data.popularCurrencies
            sectionTitles.insert(Constants.popularSectionTitle, at: 0)
        }

        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension CurrenciesTableViewManager: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredCurrenciesDictionary.removeAll(keepingCapacity: false)
        if let searchText = searchController.searchBar.text {
            filteredCurrenciesDictionary = currenciesDictionary
                .mapValues {
                    $0.filter {
                        $0.displayName.lowercased().contains(searchText.lowercased())
                    }
                }
                .filter { !$0.value.isEmpty }
        }
        filteredSectionTitles = [String](filteredCurrenciesDictionary.keys)
        filteredSectionTitles = filteredSectionTitles.sorted { $0 < $1 }
        if let index = filteredSectionTitles.firstIndex(of: Constants.popularSectionTitle) {
            filteredSectionTitles.remove(at: index)
            filteredSectionTitles.insert(Constants.popularSectionTitle, at: 0)
        }

        tableView?.reloadData()
    }
}

// MARK: TableViewDelegate

extension CurrenciesTableViewManager: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currencyKey = currentSectionTitles[indexPath.section]
        if let section = currentCurrenciesDataSource[currencyKey],
           let currencyData = section[safe: indexPath.row] {
            delegate?.currenciesTableViewManager(self, didSelectCurrency: currencyData.code)
        }
    }
}

// MARK: - Data Source

extension CurrenciesTableViewManager: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return currentSectionTitles.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currencyKey = currentSectionTitles[section]
        if let values = currentCurrenciesDataSource[currencyKey] {
            return values.count
        }

        return 0
    }

    func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Constants.headerTextColor
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDefaultTableViewCellIdentifier, for: indexPath)

        let currencyKey = currentSectionTitles[indexPath.section]
        if let values = currentCurrenciesDataSource[currencyKey],
           let cellData = values[safe: indexPath.row] {
            cell.textLabel?.text = cellData.displayName
        }

        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentSectionTitles[section]
    }
}

// MARK: - Models

extension CurrenciesTableViewManager {
    struct Model: Equatable {
        struct CurrencyData: Equatable {
            let code: String
            let displayName: String
        }

        private(set) var currencies: [CurrencyData]
        private(set) var popularCurrencies: [CurrencyData]

        init(popularCurrencies: [CurrencyData] = [], currencies: [CurrencyData] = []) {
            self.popularCurrencies = popularCurrencies
            self.currencies = currencies
        }

        static func == (lhs: CurrenciesTableViewManager.Model, rhs: CurrenciesTableViewManager.Model) -> Bool {
            return lhs.currencies == rhs.currencies
        }
    }
}

// MARK: - Constants

extension CurrenciesTableViewManager {
    private enum Constants {
        static let popularSectionTitle = "Popular"
        static let headerTextColor = UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
    }
}
