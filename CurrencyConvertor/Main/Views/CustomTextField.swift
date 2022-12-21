//
//  CustomTextField.swift
//  CurrencyConvertor
//
//

import Foundation
import SnapKit
import UIKit

class CustomTextField: UITextField {
    // MARK: - Properties

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfiguration()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultConfiguration()
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        buildUI()
        addEditingTextFieldTargets()
    }

    private func buildUI() {
        func configureColors() {
            textColor = Constants.textColor
            tintColor = Constants.textColor
            backgroundColor = Constants.backgroundColor
        }

        configureBorderLook()
        configureColors()
        layer.cornerRadius = Constants.cornerRadius
        autocapitalizationType = .none
        clipsToBounds = true
        borderStyle = .none
        returnKeyType = .done
    }

    private func addEditingTextFieldTargets() {
        addTarget(self, action: #selector(editingBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
    }

    // MARK: - UI

    private func configureBorderLook() {
        if isEditing {
            layer.borderColor = Constants.Border.focusedColor
            layer.borderWidth = Constants.Border.focusedWidth
        } else {
            layer.borderColor = Constants.Border.unfocusedColor
            layer.borderWidth = Constants.Border.unfocusedWidth
        }
    }

    // MARK: - Actions

    @objc private func editingBegin(_: UITextField) {
        configureBorderLook()
    }

    @objc private func editingEnd(_: UITextField) {
        configureBorderLook()
    }
}

// MARK: - Override

extension CustomTextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: Constants.padding.dx, dy: Constants.padding.dy)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

// MARK: - Constants

extension CustomTextField {
    private enum Constants {
        static let backgroundColor = UIColor(red: 0.969, green: 0.973, blue: 0.984, alpha: 1)
        static let cornerRadius: CGFloat = 6.0
        static let padding: (dx: CGFloat, dy: CGFloat) = (dx: 8.0, dy: 7.0)
        static let textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 1)
        enum Border {
            static let focusedColor = CGColor(red: 0, green: 0.478, blue: 1, alpha: 1)
            static let focusedWidth: CGFloat = 1.0
            static let unfocusedColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            static let unfocusedWidth: CGFloat = 0.0
        }
    }
}
