//
//  MainViewController.swift
//  CurrencyConvertor
//
//

import BetterSegmentedControl
import Foundation
import RxSwift
import SnapKit
import UIKit

class MainViewController: UIViewController {
    // MARK: - Properties

    private let currencyConvertorStackViewManager = CurrencyConvertorStackViewManager()
    private let viewModel = ConvertorViewModel()
    private let disposeBag = DisposeBag()
    private let currencyExchangeTypes = [
        ExchangeType.sell,
        ExchangeType.buy,
    ]

    // MARK: UI

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let scrollViewContentView = UIView()
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: Constants.backgroundImageName)
        imageView.image = image
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    private let contentView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.CurrencyConvertorTitle.attributedText
        return label
    }()
    private lazy var convertorView: ConvertorView = {
        let view = ConvertorView(exchangeRateTypes: .init(currencyExchangeTypes: currencyExchangeTypes))
        return view
    }()
    private let lastUpdateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle

    override func loadView() {
        view = buildView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        defaultConfiguration()
    }

    // MARK: Configurations

    private func buildView() -> UIView {
        let view = UIView()

        // scrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // scrollViewContentView
        scrollView.addSubview(scrollViewContentView)
        scrollViewContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }
        // backgroundView
        scrollViewContentView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.width.equalToSuperview()
        }
        // contentView
        scrollViewContentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.top.equalTo(scrollViewContentView.safeAreaLayoutGuide).offset(Constants.viewSpacing)
            make.trailing.bottom.equalTo(scrollViewContentView.safeAreaLayoutGuide).offset(-Constants.viewSpacing)
        }
        // titleLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.titleLabelTopOffset)
        }
        // convertorView
        contentView.addSubview(convertorView)
        convertorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.viewSpacing * 2)
        }
        // lastUpdateLabel
        contentView.addSubview(lastUpdateLabel)
        lastUpdateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(convertorView.snp.bottom).offset(Constants.viewSpacing)
            make.bottom.lessThanOrEqualToSuperview()
        }

        return view
    }

    private func defaultConfiguration() {
        view.backgroundColor = UIColor.white
        navigationController?.isNavigationBarHidden = true

        viewModel.onControllerDefaultConfiguration(exchangeType: currencyExchangeTypes[0])

        currencyConvertorStackViewManager.contentView = view
        currencyConvertorStackViewManager.stackView = convertorView.currencyConvertorStackView
        currencyConvertorStackViewManager.delegate = self

        convertorView.delegate = self

        addKeyboardObservers()
        hideKeyboardOnTappedAround()
    }

    // MARK: - Methods

    private func updateConvertorStackViewModel(_ data: [ConvertorManager.ConvertedCurrencyData]) {
        let currencyCells = data.map {
            CurrencyConvertorStackViewRow.Model(
                currencyLabelText: $0.currencyCode,
                currencyTextFieldPlaceholder: $0.currencyValue,
                clearTextField: !$0.isMainCurrency,
                showRemoveButton: data.count > Constants.minimumCurrenciesCount
            )
        }
        currencyConvertorStackViewManager.model = .init(rows: currencyCells)
    }

    private func updateLastUpdateLabel(updateDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: GlobalConstants.localeIdentifier)
        formatter.dateFormat = Constants.LastUpdateLabel.dateFormat
        let formattedDate = formatter.string(from: updateDate)
        DispatchQueue.main.async {
            self.lastUpdateLabel.attributedText = NSAttributedString(
                attributedString: Constants.LastUpdateLabel.attributedText,
                newString: String(
                    format: Constants.LastUpdateLabel.textFormat,
                    formattedDate
                )
            )
        }
    }

    private func showAddCurrencyScreen(withData data: AddCurrencyViewController.Data) {
        DispatchQueue.main.async { [weak self] in
            let viewController = AddCurrencyViewController(data: data)
            viewController.delegate = self
            self?.present(UINavigationController(rootViewController: viewController), animated: true)
        }
    }
}

// MARK: - Keyboard

extension MainViewController {
    private func hideKeyboardOnTappedAround() {
        let endEditingTapRecognizer = UITapGestureRecognizer(
            target: contentView,
            action: #selector(UIView.endEditing)
        )
        endEditingTapRecognizer.cancelsTouchesInView = false
        contentView.addGestureRecognizer(endEditingTapRecognizer)
    }

    private func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        if show {
            if let userInfo = notification.userInfo,
               let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                scrollView.contentInset.bottom = keyboardFrame.cgRectValue.height
                scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.cgRectValue.height
            }
        } else {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
}

// MARK: - RX -

extension MainViewController {
    private func subscribe() {
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        viewModel.model
            .subscribe(onNext: { [weak self] model in
                guard let data = model else { return }
                self?.updateLastUpdateLabel(updateDate: data.updateTime)
            })
            .disposed(by: disposeBag)
        viewModel.convertedCurrencies
            .subscribe(onNext: { [weak self] model in
                guard let data = model else { return }
                self?.updateConvertorStackViewModel(data)
            })
            .disposed(by: disposeBag)
        viewModel.showAddCurrencyScreen
            .subscribe(onNext: { [weak self] model in
                guard let data = model else { return }
                self?.showAddCurrencyScreen(withData: data)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: ScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - CurrencyConvertorStackViewManagerDelegate

extension MainViewController: CurrencyConvertorStackViewManagerDelegate {
    func onCurrencyTextFieldValueChanged(_ value: Double?, forRowAt index: Int) {
        viewModel.onCurrencyTextFieldValueChanged(value, forRowAt: index)
    }

    func didPressRemoveCurrencyButton(forRowAt index: Int) {
        viewModel.onRemoveCurrencyButtonTapped(forRowAt: index)
    }
}

// MARK: - ConvertorViewDelegate

extension MainViewController: ConvertorViewDelegate {
    func convertorView(didChangeSegmentedControlValue segmentedControl: BetterSegmentedControl) {
        let selectedIndex = [MainViewController.ExchangeType].Index(segmentedControl.index)
        if let exchangeType = currencyExchangeTypes[safe: selectedIndex] {
            viewModel.onSegmedntedControlValueChanged(exchangeType)
        }
    }

    func convertorView(didPressAddButton _: UIButton) {
        viewModel.onAddButtonTapped()
    }

    func convertorView(didPressShareButton _: UIButton) {
        var text = ""
        for cell in currencyConvertorStackViewManager.model?.rows ?? [] {
            text += cell.currencyLabelText + " " + cell.currencyTextFieldPlaceholder + "\n"
        }
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.postToFacebook,
        ]
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - AddCurrencyViewControllerDelegate

extension MainViewController: AddCurrencyViewControllerDelegate {
    func addCurrencyViewController(_ viewController: AddCurrencyViewController, didSelectCurrency currencyCode: String) {
        viewModel.onCurrencySelect(currencyCode)
        viewController.dismiss()
    }
}

// MARK: - Models

extension MainViewController {
    enum ExchangeType {
        case sell, buy
        var description: String {
            switch self {
            case .sell: return Constants.ExchangeTypes.sell
            case .buy: return Constants.ExchangeTypes.buy
            }
        }
    }
}

// MARK: - Constants

extension MainViewController {
    private enum Constants {
        static let viewSpacing: CGFloat = 16.0
        static let titleLabelTopOffset: CGFloat = 60.0
        static let backgroundImageName = "header"
        static let minimumCurrenciesCount = 3
        enum ExchangeTypes {
            static let sell = "Sell"
            static let buy = "Buy"
        }
        enum CurrencyConvertorTitle {
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.42
                return NSAttributedString(
                    string: "Currency Converter",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.latoFont(ofSize: 24.0, weight: .bold),
                        .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                    ]
                )
            }()
        }
        enum LastUpdateLabel {
            static let textFormat = "Last Updated\n%@"
            static let dateFormat = "d MMMM yyyy h:mm a"
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.46
                return NSAttributedString(
                    string: " ",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.latoFont(ofSize: 12.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1),
                    ]
                )
            }()
        }
    }
}
