//
//  ProductsViewController.swift
//  TopGift
//
//  Created by iosdev on 17.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

extension Array where Element: Equatable {
    func all(where predicate: (Element) -> Bool) -> [Element]  {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}
/// ProductsViewController.swift
/// TopGift
///
/// This class fetches the clothes data using api_data class and then displays the data. FIltering the data happens inside api_data but parameters for filtering is passed here or filter functions are called
class ProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var maxPrice = ""
    var minPrice = ""
    var category = ""
    var size = ""
    
    var products = [Products]()
    var colors = [Color]()
    var initialProducts = [Products]()
    
    var items = [Item]()
    var image = UIImage()
    var zalando = ApiData(completionBlock: {(items) -> Void in print(items)})
    var isLoading = false
    
    /* Loading indicator & No results label is displayed */
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noResultsLabel: UILabel!
    /* END */
    
    @IBOutlet weak var ProductsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start animating the loading activity
        activityIndicator.startAnimating()
        noResultsLabel.text = ""
        /* END */
        
        // Searchbar delegate setup
        searchBar.delegate = self
        
        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        
        ProductsCollectionView.delegate = self
        ProductsCollectionView.dataSource = self
        
        //function that fetches the api data
        //completionblock as a parameter to wait function completion
        zalando = ApiData(completionBlock: {(items) -> Void in
            let photo1 = UIImage(named: "sample1")
            
            guard let product1 = Products(pName: "shirt", price: 20.5, size: "M", color: "black", pPhoto: photo1, desc: "You can buy this great product from Zalando Zircle store", id: "default id")
            else {
                fatalError("unable to instantiate p1")
            }
            self.items = items
            
            if (items.isEmpty) {
                DispatchQueue.main.async {
                    self.noResultsLabel.text = "No results were found."
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            for item in items{
                
                DispatchQueue.global().async {
                    
                    guard let imageUrl = URL(string: item.images?[0].url ?? "") else {
                        return
                    }
                    //imageUrl loaded/changed to UIImage
                    let data = try? Data(contentsOf: imageUrl)
                    
                    var image = UIImage(named: "defaultPhoto")
                    
                    if let imageData = data {
                        image = UIImage(data: imageData)
                    }
                    
                    //product created with fetched data and image added
                    let product = Products(pName: item.brand ?? "", price: item.price.amount, size: item.size ?? "", color: "\(item.color ?? Color.none)", pPhoto: image, desc: "You can buy this great product from Zalando Zircle store. Just add it to your basket!", id: item.id )
                    
                    self.products.append(product ?? product1)
                    
                    // initialProducts array is used for SearchBarDelegate. When search text is cleared - reload collectionView to initial items.
                    self.initialProducts.append(product ?? product1)
                    
                    DispatchQueue.main.async {
                        //view reloaded
                        self.collectionView.reloadData()
                        self.isLoading = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        //checks if filters are applied and used
        if category != "" {
            zalando.setCategorys(categorys: [category])
        }
        if size != "" {
            zalando.setSizes(sizes: [size])
        }
        if colors.count > 0{
            zalando.colorFilters = colors
        }
        
        zalando.minPrice = Double(minPrice) ?? 0.0
    
        zalando.maxPrice = Double(maxPrice) ?? 1000.0
        
        let photo2 = UIImage(named: "sample2")
        func setImage(from url: String) -> UIImage {
            
            guard let imageURL = URL(string: url) else { return photo2!}
            
            // just not to cause a deadlock in UI!
            DispatchQueue.global().async {
                
                guard let imageData = try? Data(contentsOf: imageURL) else { return }
                
                self.image = UIImage(data: imageData)!

            }

            return image
        }
        
        // Fetch items from Zalando API
        loadSampleData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let ident = "Cell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ident, for: indexPath) as? ProductsCollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of ProductsViewCell.")
        }
        
        let product = products[indexPath.row]
        
        cell.productNameLabel.text = "Product: \(product.pName)"
        cell.priceLabel.text = "Price: \(product.price)€"
        cell.imageView.image = product.pPhoto
        
        return cell
    }
    
    ///Function for loading new page of products when scrolled down through products
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //checks if view is in certain place and loads more products
        if (offsetY > contentHeight - scrollView.frame.height * 2) && !isLoading {
            isLoading = true
            zalando.page += 1
            zalando.getZalandoItemFeed()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        //after loading changes loading bool to false to stop loading more pages.
        if (offsetY < contentHeight - scrollView.frame.height * 2) && isLoading {
            print(products.count)
            isLoading = false
        }
        
        
    }
    
    //Segue for sending needed data to show only one item
    // checks also which cell is pressed and if segue identifier is right
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        
        case "ShowDetail":
            guard let itemDetailViewController = segue.destination as? OneProductViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? ProductsCollectionViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = collectionView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = products[indexPath.row]
            
            itemDetailViewController.productName = selectedItem.pName
            itemDetailViewController.price = selectedItem.price
            itemDetailViewController.color = selectedItem.color
            itemDetailViewController.desc = selectedItem.desc
            itemDetailViewController.pPhoto = selectedItem.pPhoto
            itemDetailViewController.size = selectedItem.size
            itemDetailViewController.id = selectedItem.id
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // Fetch items from Zalando API
    private func loadSampleData() {
        zalando.getZalandoItemFeed()
    }
}

// searchbar
// MARK: - UISearchBarDelegate
extension ProductsViewController: UISearchBarDelegate {
    
    func searchForForProducts() {
        guard let searchText = searchBar.text else {
            return
        }
        
        // Set filtering request
        
        if !searchText.isEmpty {
            
            let filteredProducts = products.filter {
                $0.pName.range(of: searchText, options: .caseInsensitive) != nil
            }
            
            self.products = filteredProducts
            
        } else {
            
            products = initialProducts
            
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        
        products = initialProducts
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForForProducts()
    }
}
