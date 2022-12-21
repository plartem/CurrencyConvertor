//
//  CurrencyConvertorStackViewRow.swift
//  CurrencyConvertor
//
//

import Foundation
import SnapKit
import UIKit

protocol CurrencyConvertorStackViewRowDelegate: AnyObject {
    func currencyConvertorStackViewRow(
        _ currencyConvertorStackViewRow: CurrencyConvertorStackViewRow,
        shouldChangeCurrencyText text: String
    )
    func currencyConvertorStackViewRow(
        _ currencyConvertorStackViewRow: CurrencyConvertorStackViewRow,
        didPressRemoveCurrencyButton button: UIButton
    )
}

class CurrencyConvertorStackViewRow: UIView {
    // MARK: - Properties

    weak var delegate: CurrencyConvertorStackViewRowDelegate?

    /// Update from main queue only
    var model: Model? {
        didSet {
            updateUI()
        }
    }

    var removeButtonWidthConstraint: Constraint?

    // MARK: UI

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constants.textColor
        label.attributedText = Constants.currencyLabelAttributedText
        return label
    }()
    private let greaterThanImageView: UIImageView = {
        let imageView = UIImageView(image: Constants.GreaterThanSymbol.image)
        imageView.tintColor = Constants.textColor
        return imageView
    }()
    private let currencyTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.font = Constants.CurrencyTextField.font
        textField.keyboardType = .numbersAndPunctuation
        return textField
    }()
    private lazy var removeButton: UIButton = {
        let button = UIButton(configuration: Constants.RemoveButton.config)
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Configuration

    private func buildUI() {
        // currencyLabel
        addSubview(currencyLabel)
        currencyLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        // greaterThanImageView
        addSubview(greaterThanImageView)
        greaterThanImageView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.equalToSuperview().offset(Constants.GreaterThanSymbol.leadingOffset)
            make.centerY.equalToSuperview()
        }
        // currencyTextField
        addSubview(currencyTextField)
        currencyTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(greaterThanImageView.snp.trailing).offset(Constants.CurrencyTextField.leadingOffset)
            make.height.equalTo(Constants.CurrencyTextField.height)
            make.width.equalToSuperview().priority(.low)
        }
        // removeButton
        addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(currencyTextField.snp.trailing)
            make.trailing.equalToSuperview()
            removeButtonWidthConstraint = make.width.equalTo(Constants.RemoveButton.width).constraint
        }

        addSubview(currencyLabel)
        currencyLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func defaultConfiguration() {
        currencyTextField.delegate = self
    }

    // MARK: - Methods

    private func updateUI() {
        guard let data = model else { return }
        // currencyLabel
        if data.currencyLabelText.isEmpty {
            currencyLabel.removeAttributedText()
        } else {
            currencyLabel.updateAttributedText(data.currencyLabelText)
        }
        // currencyTextField
        if data.clearTextField {
            currencyTextField.text = ""
            currencyTextField.attributedPlaceholder = NSAttributedString(
                attributedString: Constants.CurrencyTextField.attributedPlaceholder,
                newString: data.currencyTextFieldPlaceholder
            )
        } else {
            currencyTextField.placeholder = ""
        }
        UIView.animate(withDuration: Constants.animationDuration, animations: { [weak self] in
            if data.showRemoveButton {
                self?.removeButtonWidthConstraint?.update(offset: Constants.RemoveButton.width)
            } else {
                self?.removeButton.alpha = 0.0
            }
            self?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                if data.showRemoveButton {
                    self?.removeButton.isHidden = false
                    self?.removeButton.alpha = 1.0
                } else {
                    self?.removeButton.isHidden = true
                    self?.removeButtonWidthConstraint?.update(offset: 0.0)
                }
                self?.layoutIfNeeded()
            })
        })
    }

    // MARK: - Actions

    @objc private func removeButtonTapped(sender button: UIButton) {
        delegate?.currencyConvertorStackViewRow(self, didPressRemoveCurrencyButton: button)
    }
}

// MARK: - TextFieldDelegate

extension CurrencyConvertorStackViewRow: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        endEditing(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            let isValid = Constants.CurrencyTextField.textPredicate.evaluate(with: updatedText)
            if isValid {
                delegate?.currencyConvertorStackViewRow(self, shouldChangeCurrencyText: updatedText)
            }
            return isValid
        }
        return true
    }
}

// MARK: - Model

extension CurrencyConvertorStackViewRow {
    struct Model: Equatable {
        let currencyLabelText: String
        let currencyTextFieldPlaceholder: String
        let clearTextField: Bool
        let showRemoveButton: Bool
    }
}

// MARK: - Constants

extension CurrencyConvertorStackViewRow {
    private enum Constants {
        static let textColor = UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
        static let animationDuration: CGFloat = 0.5

        static let currencyLabelAttributedText: NSAttributedString = {
            NSAttributedString(
                string: " ",
                attributes: [
                    .font: UIFont.latoFont(ofSize: 14.0),
                    .foregroundColor: Constants.textColor,
                ]
            )
        }()

        enum GreaterThanSymbol {
            static let leadingOffset: CGFloat = 40.0
            static let image: UIImage? = {
                let configuration = UIImage.SymbolConfiguration(pointSize: 14.0)
                let image = UIImage(
                    systemName: "chevron.forward",
                    withConfiguration: configuration
                )
                return image
            }()
        }

        enum CurrencyTextField {
            static let leadingOffset: CGFloat = 45.0
            static let height: CGFloat = 44.0
            static let font = UIFont.latoFont(ofSize: 14.0)
            static let textPredicate: NSPredicate = {
                let numberRegex = "^([0-9]+(\\.([0-9]{0,2})?)?)?$"
                return NSPredicate(format: "SELF MATCHES %@", numberRegex)
            }()
            static let attributedPlaceholder: NSAttributedString = {
                var paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.25

                return NSAttributedString(
                    string: " ",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: font,
                        .foregroundColor: UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1),
                    ]
                )
            }()
        }

        enum RemoveButton {
            static let width: CGFloat = 50.0
            static let config: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.borderless()
                buttonConfig.image = UIImage(systemName: "xmark.circle")
                return buttonConfig
            }()
        }
    }
}
