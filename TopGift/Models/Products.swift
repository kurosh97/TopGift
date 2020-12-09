//
//  Products.swift
//  TopGift
//
//  Created by iosdev on 17.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//


import UIKit
/// Products.swift
/// TopGift
///
/// class  that makes it possible to create products objects

class Products {
    
    //MARK: Properties
    var pName: String
    var price: Double
    var size: String
    var color: String
    var pPhoto: UIImage?
    var desc: String
    var id: String
    
    init?(pName: String, price: Double, size: String, color: String, pPhoto: UIImage?, desc: String, id: String) {
        
        guard !pName.isEmpty else {
            return nil
        }
        
        self.pName = pName
        self.price = price
        self.size = size
        self.color = color
        self.pPhoto = pPhoto
        self.desc = desc
        self.id = id
        
    }
}
