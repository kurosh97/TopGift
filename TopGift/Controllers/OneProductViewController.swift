//
//  OneProductViewController.swift
//  TopGift
//
//  Created by iosdev on 17.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//


import UIKit

/// OneProductViewController.swift
/// TopGift
///
/// This class displays one product info and has functionality for adding that product in to basket

class OneProductViewController: UIViewController {


    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var sizeLabel: UITextField!
    
    @IBOutlet weak var pImageView: UIImageView!
    @IBOutlet weak var addCartButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    
    var color = ""
    var desc = ""
    var productName = ""
    var price = 0.0
    var pPhoto: UIImage?
    var size = ""
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProductInfo()
        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        //disabling user inputs to from sizeLabel and description textfield
        sizeLabel.isUserInteractionEnabled = false;
        descText.isUserInteractionEnabled = false;
        // Do any additional setup after loading the view.
    }

    @IBAction func backAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    
    func setProductInfo(){
        nameLabel.text = productName
        priceLabel.text = "\(price)€"
        colorLabel.text = color
        descText.text = desc
        pImageView.image = pPhoto
        sizeLabel.text = "Size: \(size)"
        
    }
    //product to basket
    @IBAction func addToCartAction(_ sender: UIButton) {
        let productToCart = Products(pName: productName, price: price, size: size, color: color, pPhoto: pPhoto, desc: desc, id: id)!
        
        let basket = Basket()
        basket.addItemToBasket(cartProduct: productToCart)
        //after adding item toast is displayed
        showToast(controller: self, message: "Product added into basket", seconds: 1.5)
    }
    
    //functionality for the toast which is displayed in the view
    func showToast(controller: UIViewController, message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        //toast settings
        alert.view.backgroundColor = .green
        alert.view.alpha = 1.0
        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated: true)
        
        //removes toast after x amount of time
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

