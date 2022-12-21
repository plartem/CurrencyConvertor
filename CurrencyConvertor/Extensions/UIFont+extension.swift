//
//  UIFont+extension.swift
//  CurrencyConvertor
//
//

import Foundation
import UIKit

extension UIFont {
    static func latoFont(ofSize size: CGFloat = 13, weight: Weight = .regular) -> UIFont {
        let latoFontName: String
        switch weight {
        case .bold:
            latoFontName = "Lato-Bold"
        case .light:
            latoFontName = "Lato-Light"
        case .regular:
            latoFontName = "Lato-Regular"
        default:
            latoFontName = ""
        }
        return UIFont(name: latoFontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
