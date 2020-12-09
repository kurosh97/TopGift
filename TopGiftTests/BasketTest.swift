//
//  BasketTest.swift
//  TopGiftTests
//
//  Created by iosdev on 30.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import XCTest
@testable import TopGift

class BasketTest: XCTestCase {
    
    let basket = Basket()
    
    func testAddItemToBasket() {
        
        let photo1 = UIImage(named: "sample1")
        let product = Products(pName: "Test", price: 2.0, size: "M", color: "black", pPhoto: photo1, desc: "test", id: "1")
        basket.addItemToBasket(cartProduct: product!)
        let product2 = Products(pName: "Test", price: 3.0, size: "M", color: "black", pPhoto: photo1, desc: "test", id: "2")
        basket.addItemToBasket(cartProduct: product2!)
        
        let result = basket.getBasketData()
        XCTAssertNotNil(result)
        XCTAssertTrue(product === result[0])
    }
    
    func testRemoveItemFromBasket() {
        basket.removeFromBasket(item: 1)
        XCTAssertEqual(basket.getBasketData().count, 1)
        basket.removeFromBasket(item: 0)
        XCTAssertEqual(basket.getBasketData().count, 0)
    }
}
