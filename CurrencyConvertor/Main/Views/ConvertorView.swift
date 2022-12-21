//
//  ConvertorView.swift
//  CurrencyConvertor
//
//

import BetterSegmentedControl
import Foundation
import UIKit

protocol ConvertorViewDelegate: AnyObject {
    func convertorView(
        didChangeSegmentedControlValue segmentedControl: BetterSegmentedControl
    )
    func convertorView(
        didPressAddButton button: UIButton
    )
    func convertorView(
        didPressShareButton button: UIButton
    )
}

class ConvertorView: UIView {
    // MARK: - Properties

    weak var delegate: ConvertorViewDelegate?
    private let exchangeRateTypes: Model

    // MARK: UI

    private let contentView = UIView()
    private lazy var currencyExchangeTypeSegmentedControl: BetterSegmentedControl = {
        let segmentedControl = BetterSegmentedControl()
        segmentedControl.segments = LabelSegment.segments(
            withTitles: exchangeRateTypes.currencyExchangeTypes.map({ $0.description }),
            numberOfLines: 1,
            normalBackgroundColor: Constants.CurrencyExchangeTypesSegmentedControl.Normal.backgroundColor,
            normalFont: Constants.CurrencyExchangeTypesSegmentedControl.font,
            normalTextColor: Constants.CurrencyExchangeTypesSegmentedControl.Normal.titleColor,
            selectedBackgroundColor: Constants.CurrencyExchangeTypesSegmentedControl.Selected.backgroundColor,
            selectedFont: Constants.CurrencyExchangeTypesSegmentedControl.font,
            selectedTextColor: Constants.CurrencyExchangeTypesSegmentedControl.Selected.titleColor
        )
        segmentedControl.setOptions([
            .backgroundColor(Constants.CurrencyExchangeTypesSegmentedControl.backgroundColor),
            .cornerRadius(Constants.CurrencyExchangeTypesSegmentedControl.cornerRadius),
            .indicatorViewBackgroundColor(Constants.CurrencyExchangeTypesSegmentedControl.Selected.backgroundColor),
        ])
        return segmentedControl
    }()
    private(set) lazy var currencyConvertorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.currencyContentSpacing
        return stackView
    }()
    private lazy var addCurrencyButton: UIButton = {
        let button = UIButton(configuration: Constants.AddCurrencyButton.config)
        button.addTarget(self, action: #selector(addCurrencyButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton(configuration: Constants.ShareButton.config)
        button.tintColor = Constants.ShareButton.tintColor
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    init(exchangeRateTypes: Model) {
        self.exchangeRateTypes = exchangeRateTypes
        super.init(frame: .zero)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        backgroundColor = Constants.ContentView.backgroundColor
        layer.cornerRadius = Constants.ContentView.cornerRadius
        // shadow
        layer.shadowColor = Constants.shadowColor.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOffset = Constants.shadowOffset

        currencyExchangeTypeSegmentedControl.addTarget(
            self,
            action: #selector(currencyExchangeTypeSegmentedControlValueChanged),
            for: .valueChanged
        )
        hideKeyboardOnTappedAround()
    }

    private func buildUI() {
        // contentView
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(Constants.viewSpacing)
            make.trailing.equalToSuperview().offset(-Constants.viewSpacing)
        }
        // currencyExchangeTypeSegmentedControl
        contentView.addSubview(currencyExchangeTypeSegmentedControl)
        currencyExchangeTypeSegmentedControl.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Constants.CurrencyExchangeTypesSegmentedControl.height)
        }
        // currencyConvertorStackView
        contentView.addSubview(currencyConvertorStackView)
        currencyConvertorStackView.snp.makeConstraints { make in
            make.top.equalTo(currencyExchangeTypeSegmentedControl.snp.bottom).offset(Constants.viewSpacing)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.convertorStackViewWidth)
        }
        // addCurrencyButton
        contentView.addSubview(addCurrencyButton)
        addCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(currencyConvertorStackView.snp.bottom).offset(Constants.AddCurrencyButton.topOffset)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.AddCurrencyButton.height)
        }
        // shareButton
        addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.AddCurrencyButton.height)
        }
    }

    private func hideKeyboardOnTappedAround() {
        let endEditingTapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIView.endEditing)
        )
        endEditingTapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(endEditingTapRecognizer)
    }

    // MARK: - Actions

    @objc private func addCurrencyButtonTapped(sender button: UIButton) {
        delegate?.convertorView(didPressAddButton: button)
    }

    @objc private func shareButtonTapped(sender button: UIButton) {
        delegate?.convertorView(didPressShareButton: button)
    }

    @objc private func currencyExchangeTypeSegmentedControlValueChanged(_ segmentedControl: BetterSegmentedControl) {
        delegate?.convertorView(didChangeSegmentedControlValue: segmentedControl)
    }
}

// MARK: - Model

extension ConvertorView {
    struct Model {
        let currencyExchangeTypes: [MainViewController.ExchangeType]
    }
}

// MARK: - Constants

extension ConvertorView {
    private enum Constants {
        static let viewSpacing: CGFloat = 16.0
        static let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        static let shadowOpacity: Float = 1.0
        static let shadowRadius: CGFloat = 4.0
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let currencyContentSpacing: CGFloat = 15.0
        static let convertorStackViewWidth: CGFloat = 310.0
        enum ContentView {
            static let cornerRadius: CGFloat = 15.0
            static let backgroundColor = UIColor.white
        }
        enum CurrencyExchangeTypesSegmentedControl {
            static let height: CGFloat = 44.0
            static let cornerRadius: CGFloat = 6.0
            static let font = UIFont.latoFont(ofSize: 18.0, weight: .regular)
            static let backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            enum Selected {
                static let titleColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                static let backgroundColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
            }
            enum Normal {
                static let titleColor = UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
                static let backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
            }
        }
        enum AddCurrencyButton {
            static let topOffset: CGFloat = 52.0
            static let height: CGFloat = 44.0
            static let attributedTitle: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                return NSAttributedString(
                    string: "Add currency",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .foregroundColor: UIColor(red: 0, green: 0.478, blue: 1, alpha: 1),
                        .font: UIFont.latoFont(ofSize: 13.0, weight: .regular),
                    ]
                )
            }()
            static let config: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.borderless()
                buttonConfig.attributedTitle = .init(Constants.AddCurrencyButton.attributedTitle)
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.latoFont(ofSize: 13.0))
                buttonConfig.image = UIImage(systemName: "plus.circle.fill", withConfiguration: imageConfig)
                buttonConfig.imagePadding = 8.0
                return buttonConfig
            }()
        }
        enum ShareButton {
            static let tintColor = UIColor(red: 0.62, green: 0.616, blue: 0.624, alpha: 1)
            static let config: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.borderless()
                buttonConfig.image = UIImage(systemName: "square.and.arrow.up")
                return buttonConfig
            }()
        }
    }
}
