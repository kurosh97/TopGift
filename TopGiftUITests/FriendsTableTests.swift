
//
//  FriendsTableTests.swift
//  TopGiftUITests
//
//  Created by Micky on 30.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import XCTest
import UIKit
import Foundation

class FriendsTableTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        
        
        // We send a command line argument to our app,
        // to enable it to reset its state
        app.launchArguments.append("--uitesting")
        
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
    }
    
    func testAddNewFriend_WithFullName() throws {
        app.navigationBars["Home"].buttons["Add"].tap()
        
        let textField = app.scrollViews.otherElements.textFields["fullNameInput"]
        
        textField.tap()
        
        textField.clearAndEnterText("Matti Meikalainen")
        
        app.keyboards.buttons["Return"].tap()
        
        XCTAssertEqual(textField.value as? String ?? "", "Matti Meikalainen")
        
        app.navigationBars["Matti Meikalainen"].buttons["saveFriendBtn"].tap()
        
        // The Friends Table View is now visible
        let tableView = app.tables.containing(.table, identifier: "FriendsTable")
        
        let cell = tableView.cells.element(boundBy: 0)
        let fullNameText = cell.staticTexts["FriendFullName"].label
        
        XCTAssertEqual(fullNameText, "Matti Meikalainen")
    }
}


extension XCUIElement
{
    enum direction : Int {
        case Up, Down, Left, Right
    }
    
    func gentleSwipe(_ direction : direction) {
        let half : CGFloat = 0.5
        let adjustment : CGFloat = 0.15
        let pressDuration : TimeInterval = 0.05
        
        let lessThanHalf = half - adjustment
        let moreThanHalf = half + adjustment
        
        let centre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: half))
        let aboveCentre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: lessThanHalf))
        let belowCentre = self.coordinate(withNormalizedOffset: CGVector(dx: half, dy: moreThanHalf))
        let leftOfCentre = self.coordinate(withNormalizedOffset: CGVector(dx: lessThanHalf, dy: half))
        let rightOfCentre = self.coordinate(withNormalizedOffset: CGVector(dx: moreThanHalf, dy: half))
        
        switch direction {
        case .Up:
            centre.press(forDuration: pressDuration, thenDragTo: aboveCentre)
            break
        case .Down:
            centre.press(forDuration: pressDuration, thenDragTo: belowCentre)
            break
        case .Left:
            centre.press(forDuration: pressDuration, thenDragTo: leftOfCentre)
            break
        case .Right:
            centre.press(forDuration: pressDuration, thenDragTo: rightOfCentre)
            break
        }
    }
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        
        self.typeText(deleteString)
        self.typeText(text)
    }
}
