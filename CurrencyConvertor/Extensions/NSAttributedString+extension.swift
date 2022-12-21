//
//  NSAttributedString+extension.swift
//  CurrencyConvertor
//
//

import Foundation

extension NSAttributedString {
    convenience init(attributedString: NSAttributedString, newString string: String) {
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedText.mutableString.setString(string)
        self.init(attributedString: mutableAttributedText)
    }
}
