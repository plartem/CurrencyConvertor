//
//  CurrencyConvertorUITests.swift
//  CurrencyConvertorUITests
//
//

import XCTest

class CurrencyConvertorUITests: XCTestCase {
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        XCTAssert(elementsQuery.staticTexts["USD"].exists)
        XCTAssert(elementsQuery.staticTexts["EUR"].exists)
        XCTAssert(elementsQuery.staticTexts["UAH"].exists)
        XCTAssertFalse(app.buttons.matching(identifier: "close").firstMatch.exists)
        elementsQuery.staticTexts["Add currency"].tap()

        app.tables.staticTexts["GBP - British Pound"].tap()

        XCTAssert(elementsQuery.staticTexts["USD"].exists)
        XCTAssert(elementsQuery.staticTexts["EUR"].exists)
        XCTAssert(elementsQuery.staticTexts["UAH"].exists)
        XCTAssert(elementsQuery.staticTexts["GBP"].waitForExistence(timeout: 3.0))
        XCTAssert(app.buttons.matching(identifier: "close").firstMatch.exists)

        app.buttons.matching(identifier: "close").element(boundBy: 2).tap()

        XCTAssert(elementsQuery.staticTexts["USD"].exists)
        XCTAssert(elementsQuery.staticTexts["EUR"].exists)
        XCTAssertFalse(elementsQuery.staticTexts["UAH"].exists)
        XCTAssert(elementsQuery.staticTexts["GBP"].exists)
        XCTAssertFalse(app.buttons.matching(identifier: "close").firstMatch.exists)
    }
}
