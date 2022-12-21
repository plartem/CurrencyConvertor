//
//  ConvertorViewTests.swift
//  CurrencyConvertorTests
//
//

@testable import CurrencyConvertor
import SnapshotTesting
import XCTest

class ConvertorViewTests: XCTestCase {
    func testConvertorView1() {
        let view = ConvertorView(exchangeRateTypes: .init(currencyExchangeTypes: [.sell, .buy]))
        assertSnapshot(matching: view, as: .image(size: Constants.contentViewSize))
    }

    func testConvertorRow1() {
        let view = CurrencyConvertorStackViewRow()
        view.model = .init(
            currencyLabelText: "UAH",
            currencyTextFieldPlaceholder: "153.25",
            clearTextField: true,
            showRemoveButton: false
        )
        assertSnapshot(matching: view, as: .image(size: Constants.rowSize))
    }

    func testConvertorRow2() {
        let view = CurrencyConvertorStackViewRow()
        view.model = .init(
            currencyLabelText: "UAH",
            currencyTextFieldPlaceholder: "153.25",
            clearTextField: true,
            showRemoveButton: true
        )
        assertSnapshot(matching: view, as: .image(size: Constants.rowSize))
    }

    func testConvertorRow3() {
        let view = CurrencyConvertorStackViewRow()
        view.model = .init(
            currencyLabelText: "USD",
            currencyTextFieldPlaceholder: "",
            clearTextField: true,
            showRemoveButton: true
        )
        assertSnapshot(matching: view, as: .image(size: Constants.rowSize))
    }

    func testConvertorRow4() {
        let view = CurrencyConvertorStackViewRow()
        view.model = .init(
            currencyLabelText: "USD",
            currencyTextFieldPlaceholder: "",
            clearTextField: true,
            showRemoveButton: false
        )
        assertSnapshot(matching: view, as: .image(size: Constants.rowSize))
    }
}

extension ConvertorViewTests {
    private enum Constants {
        static let contentViewSize = CGSize(width: 375.0, height: 400.0)
        static let rowSize = CGSize(width: 300.0, height: 60.0)
    }
}
