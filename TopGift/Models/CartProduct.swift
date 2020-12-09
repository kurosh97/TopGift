//
//  CartProduct.swift
//  TopGift
//
//  Created by iosdev on 9.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

class CartProduct {
    
    //MARK: Properties
    // TESTTINGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
    var pName: String
    var price: Double
    var size: String
    var color: String
    var pPhoto: UIImage?
    
    init?(pName: String, price: Double, size: String, color: String, pPhoto: UIImage?) {
        
        guard !pName.isEmpty else {
            return nil
        }
        
        self.pName = pName
        self.price = price
        self.size = size
        self.color = color
        self.pPhoto = pPhoto
        
    }
}
