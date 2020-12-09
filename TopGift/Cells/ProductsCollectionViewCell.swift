//
//  ProductsCollectionViewCell.swift
//  TopGift
//
//  Created by iosdev on 17.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

class ProductsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
}
