//
//  Basket.swift
//  TopGift
//
//  Created by iosdev on 17.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//


import UIKit

var productsInBasket = [Products]()
var observers = [BasketObserver]()

/// Basket.swift
/// TopGift
///
/// Basket class that keeps count of what items are in basket and returns them. Works with observer pattern. Is observable

class Basket: BasketObservable {
    
    
    //Observable functions
    func registerObserver(observer: BasketObserver) {
        if observers.firstIndex(where:{($0 as AnyObject) === (observer as AnyObject)}) == nil {
            observers.append(observer as AnyObject as! BasketObserver)
        }
    }
    
    func deRegisterObserver(observer: BasketObserver) {
        if let index = observers.firstIndex(where:{($0 as AnyObject) === (observer as AnyObject)}) {
            observers.remove(at: index)
        }
    }
    //adding items to basket
    //items are appended to productsInbasket array and then update function of observers is called
    func addItemToBasket(cartProduct: Products) {

        productsInBasket.append(cartProduct)
        for observer in observers {
            observer.update()
        }
    }
    //returns the array of Products inside productsInbasket
    func getBasketData() -> [Products] {
        return productsInBasket
    }
    //deletes item from productsInbasket
    //what to delete specified with parameter item which
    func removeFromBasket(item: Int) {
        productsInBasket.remove(at: item)
    }
}
