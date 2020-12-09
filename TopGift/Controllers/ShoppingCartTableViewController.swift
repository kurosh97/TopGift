//
//  ShoppingCartTableViewController.swift
//  TopGift
//
//  Created by iosdev on 9.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import os.log

/// ShoppingCartTableViewController.swift
/// TopGift
///
/// Class that handles the basket view and shows items inside basket, using table view

class ShoppingCartTableViewController: UITableViewController, BasketObserver {
    
    
    var basket = Basket()
    var cartProducts = [Products]()
    var oneProductService = OneItemData()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        //observer for basket class
        basket.registerObserver(observer: self)
        //loads the initial content
        loadSampleData()
        navigationItem.rightBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cartProducts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let ident = "ShoppingCartTableViewCell"
        
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as? ShoppingCartTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShoppingTableViewCell.")
        }
        
        let product = cartProducts[indexPath.row]
        
        cell.priceLabel.text = "\(product.price)€"
        cell.productLabel.text = product.pName
        cell.sizeLabel.text = product.size
        cell.colorLabel.text = product.color
        cell.productImageView.image = product.pPhoto
        
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            cartProducts.remove(at: indexPath.row)
            basket.removeFromBasket(item: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //segue handler
    //checks if identifier is ShowWebPage and finds out what cell is tapped
    //makes Api call to get more information about product --> fetches url
    //By using segue Url is sent to WebKitViewController
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            
            switch(segue.identifier ?? "") {
            
            case "ShowWebPage":
                guard let WebkitViewController = segue.destination as? WebKitViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let selectedProductCell = sender as? ShoppingCartTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedProductCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
          
                
                let id = cartProducts[indexPath.row].id

                let group = DispatchGroup()
                group.enter()
                
                DispatchQueue.global().async {
                    self.oneProductService.getZalandoItem(id: id, completion: {() -> Void in group.leave()})
                 
                }
                group.wait()
                
                WebkitViewController.url = URL(string: self.oneProductService.itemUrl)
                
            case "ShowProductsPage":
                os_log("Show products.", log: OSLog.default, type: .debug)
               
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            }
        
    }

    //fetches data from basket
    private func loadSampleData() {
        let basketProducts = basket.getBasketData()
        cartProducts = basketProducts

    }
    //update used from basket observable
    //once called this tableview is updated with additional new data
    func update() {

        let basketProducts = basket.getBasketData()
        cartProducts = basketProducts
        tableView.reloadData()
    }

}
