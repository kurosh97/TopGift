//
//  BasketObservable.swift
//  TopGift
//
//  Created by iosdev on 27.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import Foundation

protocol BasketObservable{
    func registerObserver(observer: BasketObserver)
    func deRegisterObserver(observer: BasketObserver)
    
}
