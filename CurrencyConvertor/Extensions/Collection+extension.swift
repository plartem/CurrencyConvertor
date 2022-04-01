//
//  Collection+extension.swift
//  CurrencyConvertor
//
//  Created by Artem Hryn on 04.01.2022.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
