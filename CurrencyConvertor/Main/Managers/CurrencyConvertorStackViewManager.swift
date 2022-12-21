//
//  CurrencyConvertorStackViewManager.swift
//  CurrencyConvertor
//
//

import Foundation
import UIKit

protocol CurrencyConvertorStackViewManagerDelegate: AnyObject {
    func onCurrencyTextFieldValueChanged(
        _ value: Double?,
        forRowAt index: Int
    )
    func didPressRemoveCurrencyButton(
        forRowAt index: Int
    )
}

class CurrencyConvertorStackViewManager: NSObject {
    // MARK: - Properties

    weak var delegate: CurrencyConvertorStackViewManagerDelegate?

    weak var contentView: UIView?
    weak var stackView: UIStackView?

    var model: Model? {
        didSet {
            reloadData(oldValue: oldValue)
        }
    }

    // MARK: - Methods

    private func reloadData(oldValue: Model? = nil) {
        guard let data = model else {
            DispatchQueue.main.async { [weak self] in
                self?.stackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
            return
        }
        guard let oldData = oldValue else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for rowModel in data.rows {
                    let rowView = self.createRow()
                    self.stackView?.addArrangedSubview(rowView)
                    rowView.model = rowModel
                }
            }
            return
        }

        var updateIndexes: [Int] = []
        var removeIndexes: [Int] = []
        var insertIndexes: [Int] = []
        var lastIndex = -1
        for row in data.rows.indices {
            if let index = oldData.rows.firstIndex(where: {
                $0.currencyLabelText == data.rows[row].currencyLabelText
            }),
                index > lastIndex {
                if oldData.rows[index] != data.rows[row] {
                    updateIndexes.append(row)
                }
                for removeIndex in lastIndex + 1 ..< index {
                    removeIndexes.append(removeIndex)
                }
                lastIndex = index
            } else {
                insertIndexes.append(row)
            }
        }
        for removeIndex in lastIndex + 1 ..< oldData.rows.count {
            removeIndexes.append(removeIndex)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.5, animations: {
                for i in removeIndexes {
                    self.stackView?.arrangedSubviews[i].isHidden = true
                    self.stackView?.arrangedSubviews[i].alpha = 0.1
                }
                self.contentView?.layoutIfNeeded()
            }, completion: { _ in
                for i in removeIndexes {
                    self.stackView?.arrangedSubviews[i].removeFromSuperview()
                }
                UIView.animate(withDuration: 0.5) {
                    for i in insertIndexes {
                        let rowView = self.createRow()
                        self.stackView?.insertArrangedSubview(rowView, at: i)
                        rowView.model = data.rows[i]
                    }
                    for i in updateIndexes {
                        if let rowView = self.stackView?.arrangedSubviews[i] as? CurrencyConvertorStackViewRow {
                            rowView.model = data.rows[i]
                        }
                    }
                    self.contentView?.layoutIfNeeded()
                }
            })
        }
    }

    private func createRow() -> CurrencyConvertorStackViewRow {
        let row = CurrencyConvertorStackViewRow()
        row.delegate = self
        return row
    }
}

// MARK: - CurrencyConvertorStackViewRowDelegate

extension CurrencyConvertorStackViewManager: CurrencyConvertorStackViewRowDelegate {
    func currencyConvertorStackViewRow(_ currencyConvertorStackViewRow: CurrencyConvertorStackViewRow, shouldChangeCurrencyText text: String) {
        if let row = stackView?.arrangedSubviews.firstIndex(of: currencyConvertorStackViewRow) {
            delegate?.onCurrencyTextFieldValueChanged(
                Double(text),
                forRowAt: row
            )
        }
    }

    func currencyConvertorStackViewRow(_ currencyConvertorStackViewRow: CurrencyConvertorStackViewRow, didPressRemoveCurrencyButton _: UIButton) {
        if let row = stackView?.arrangedSubviews.firstIndex(of: currencyConvertorStackViewRow) {
            delegate?.didPressRemoveCurrencyButton(
                forRowAt: row
            )
        }
    }
}

// MARK: - Models

extension CurrencyConvertorStackViewManager {
    struct Model: Equatable {
        let rows: [CurrencyConvertorStackViewRow.Model]
    }
}

// MARK: - Constants

extension CurrencyConvertorStackViewManager {
    private enum Constants {}
}
