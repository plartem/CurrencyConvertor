//
//  NSAttributedString+extension.swift
//  CurrencyConvertor
//
//  Created by Artem Hryn on 29.03.2022.
//

import Foundation

extension NSAttributedString {
    convenience init(attributedString: NSAttributedString, newString string: String) {
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedText.mutableString.setString(string)
        self.init(attributedString: mutableAttributedText)
    }
}
