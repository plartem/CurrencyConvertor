//
//  UILabel+extension.swift
//  CurrencyConvertor
//
//  Created by Artem Hryn on 13.01.2022.
//

import Foundation
import UIKit

extension UILabel {
    /// - Warning: If `text` is empty, attributedText will become `nil`
    func updateAttributedText(_ text: String) {
        if let attributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.mutableString.setString(text)
            self.attributedText = mutableAttributedText
        }
    }

    func removeAttributedText() {
        updateAttributedText(" ")
    }
}
