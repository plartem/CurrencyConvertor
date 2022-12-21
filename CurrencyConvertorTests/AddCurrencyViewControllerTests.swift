//
//  AddCurrencyViewControllerTests.swift
//  CurrencyConvertorTests
//
//

@testable import CurrencyConvertor
import SnapshotTesting
import XCTest

class AddCurrencyViewControllerTests: XCTestCase {
    func testController1() throws {
        let viewController = AddCurrencyViewController(data: .init(
            popularCurrencies: ["USD", "EUR"],
            currencies: ["UAH", "CZK", "GBP"]
        ))
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe))
    }

    func testController2() throws {
        let viewController = AddCurrencyViewController(data: .init(
            popularCurrencies: [],
            currencies: ["UAH", "CZK", "GBP"]
        ))
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe))
    }

    func testController3() throws {
        let viewController = AddCurrencyViewController(data: .init(
            popularCurrencies: ["USD", "EUR", "GBP"],
            currencies: ["UAH", "CZK", "GBP", "CHF"]
        ))
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe))
    }

    func testController4() throws {
        let viewController = AddCurrencyViewController(data: .init(
            popularCurrencies: [],
            currencies: []
        ))
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneSe))
    }
}
