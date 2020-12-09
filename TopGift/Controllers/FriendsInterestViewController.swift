//
//  FriendsInterestViewController.swift
//  TopGift
//
//  Created by iosdev on 21.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.


import UIKit
import RangeSeekSlider


class FriendsInterestViewController: UIViewController {
    
    private var dataDict: [String: Any?] = [:]
    
    var friend: NewFriend?
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Personality Drop Down Menu
    @IBOutlet weak var dropdownPersonalityBtn: UIButton!
    @IBOutlet weak var personalityTblView: UITableView!
    
    var personalityList = ["Energetic","Kind","Peaceful","Fun"]
    
    // Categories Drop Down Menu
    
    @IBOutlet weak var dropdownCategoriesBtn: UIButton!
    @IBOutlet weak var categoriesTblView: UITableView!
    
    var categoriesList = [String]()
    // Sizes Drop Down Menu
    
    @IBOutlet weak var dropdownSizeBtn: UIButton!
    @IBOutlet weak var sizesTblView: UITableView!
    
    let shirtsList = ["XXS","XS", "S", "M", "L", "XL", "XXL"]
    
    let shoeSizeList = ["35","35.5","36","36.5","37","37.5","38","38.5","39","39.5","40","40.5","41","41.5","42"]
    
    var sizesList: [String] = []
    
    // Selected items
    var selectedPersonality: String?
    var selectedCategory: String?
    var selectedSize: String?
    
    @IBOutlet weak var rangeSeekSlider: RangeSeekSlider!
    
    @IBOutlet weak var showProductsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup RangeSeekSlider
        setup()
        
        commonInit()
        
        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        
        updateShowProductsButtonState()
        
        let personalityArr = NSLocalizedString("Personality List", comment: "List of personalities")
        personalityList = convertToArray(str: personalityArr) ?? []
        
        let categoriesArr = NSLocalizedString("Categories List", comment: "List of categories")
        categoriesList = convertToArray(str: categoriesArr) ?? []

        // Set default table view sizes array
        sizesList = shirtsList
        
        personalityTblView.isHidden = true
        categoriesTblView.isHidden = true
        sizesTblView.isHidden = true
        
        // TableView Setup
        categoriesTblView.delegate = self
        categoriesTblView.dataSource = self
        
        personalityTblView.dataSource = self
        personalityTblView.delegate = self
        
        sizesTblView.dataSource = self
        sizesTblView.delegate = self
    }
    
    private func commonInit() {
        
        if friend?.category == nil {
            return
        }
        
        guard let data = friend else {
            return
        }
        
        dropdownCategoriesBtn.setTitle(data.category, for: .normal)
        dropdownPersonalityBtn.setTitle(data.personality, for: .normal)
        dropdownSizeBtn.setTitle(data.size, for: .normal)

        rangeSeekSlider.selectedMinValue = CGFloat(data.minPrice)
        rangeSeekSlider.selectedMaxValue = CGFloat(data.maxPrice)

        // Solution to update the slider to provided min and max values
        rangeSeekSlider.setNeedsLayout()
        rangeSeekSlider.layoutIfNeeded()
        /* END */
        
        selectedCategory = data.category
        selectedSize = data.size
        selectedPersonality = data.personality
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        friend?.category = selectedCategory ?? ""
        friend?.personality = selectedPersonality ?? ""
        friend?.size = selectedSize ?? ""
        friend?.minPrice = Double(rangeSeekSlider.selectedMinValue)
        friend?.maxPrice = Double(rangeSeekSlider.selectedMaxValue)
        
        do {
            try self.context.save()
        } catch {
            fatalError("Failed to fetch friends.")
        }
        
        guard let destinationVC = segue.destination as? ProductsViewController else {
            return
        }
        
        var colors: [Color] = []
        
        switch selectedPersonality {
        case "Energetic":
            colors = [Color.red, Color.yellow, Color.orange, Color.magentaRed,Color.black]
        case "Kind":
            colors = [Color.blueMagenta, Color.cyan, Color.green,Color.cyan,Color.blue]
        case "Peaceful":
            colors = [Color.white, Color.grey, Color.yellow, Color.blue]
        case "Fun":
            colors = [Color.greenCyan, Color.green, Color.yellowGreen, Color.orange, Color.red,Color.magenta]
        default: break
        }
        destinationVC.size = selectedSize ?? ""
        destinationVC.category = selectedCategory ?? ""
        destinationVC.minPrice = rangeSeekSlider.selectedMinValue.description
        destinationVC.maxPrice = rangeSeekSlider.selectedMaxValue.description
        destinationVC.colors = colors
    }
    
    @IBAction func pressedPersonality(_ sender: UIButton) {
        if personalityTblView.isHidden {
            animate(toggle: true, personalityTblView)
            personalityTblView.isScrollEnabled = true
        }else{
            animate(toggle: false, personalityTblView)
        }
    }
    
    @IBAction func pressedCategories(_ sender: UIButton) {
        
        if categoriesTblView.isHidden {
            animate(toggle: true, categoriesTblView)
            categoriesTblView.isScrollEnabled = true
        } else {
            animate(toggle: false, categoriesTblView)
        }
    }
    
    @IBAction func pressedSizes(_ sender: UIButton) {
        if sizesTblView.isHidden {
            animate(toggle: true, sizesTblView)
            sizesTblView.isScrollEnabled = true
        } else {
            animate(toggle: false, sizesTblView)
        }
    }
    
    func animate (toggle: Bool, _ animateTblView: UITableView){
        
        let tblView = animateTblView
        
        if toggle {
            UIView.animate(withDuration: 0.5) {
                tblView.isHidden = false
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                tblView.isHidden = true
            }
        }
    }
}


extension FriendsInterestViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case personalityTblView:
            return personalityList.count
            
        case categoriesTblView:
            return categoriesList.count
            
        case sizesTblView:
            return sizesList.count
            
        default:
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case categoriesTblView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
            
            cell.textLabel?.text = categoriesList[indexPath.row]
            return cell
        case personalityTblView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPersonality", for: indexPath)
            
            cell.textLabel?.text = personalityList[indexPath.row]
            return cell
            
        case sizesTblView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizeCell", for: indexPath)
            
            cell.textLabel?.text = sizesList[indexPath.row]
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case personalityTblView:
            dropdownPersonalityBtn.setTitle("\(personalityList[indexPath.row])", for: .normal)
            animate(toggle: false, personalityTblView)
            
        case categoriesTblView:
            dropdownCategoriesBtn.setTitle("\(categoriesList[indexPath.row])", for: .normal)
            animate(toggle: false, categoriesTblView)
            
        case sizesTblView:
            dropdownSizeBtn.setTitle("\(sizesList[indexPath.row])", for: .normal)
            animate(toggle: false, sizesTblView)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch tableView {
        case personalityTblView:
            selectedPersonality = personalityList[indexPath.row]
        case categoriesTblView:
            if (categoriesList[indexPath.row].contains(NSLocalizedString("Shoes", comment: "Shoes are the selected row."))) {
                sizesList = shoeSizeList
                
            } else {
                sizesList = shirtsList
                
            }
            
            dropdownSizeBtn.setTitle(NSLocalizedString("Size", comment: "Size")
                                     , for: .normal)
            
            selectedSize = ""
            
            DispatchQueue.main.async {
                self.sizesTblView.reloadData()
            }
            
            selectedCategory = categoriesList[indexPath.row]
            
            
        case sizesTblView:
            
            selectedSize = sizesList[indexPath.row]
        default:
            break
        }
        
        updateShowProductsButtonState()
        
        return indexPath
    }
    
    private func updateShowProductsButtonState() {
        let personality = selectedPersonality ?? ""
        let size = selectedSize ?? ""
        let category = selectedCategory ?? ""
        
        if (!personality.isEmpty && !size.isEmpty && !category.isEmpty) {
            showProductsBtn.isEnabled = true
            showProductsBtn.alpha = 1.0
        } else {
            showProductsBtn.isEnabled = false
            showProductsBtn.alpha = 0.5
        }
    }
}



// MARK: Custom RangeSeekSlider

extension FriendsInterestViewController: RangeSeekSliderDelegate {
    
    private func setup() {
        // currency range slider
        rangeSeekSlider.delegate = self
        rangeSeekSlider.minValue = 0.0
        rangeSeekSlider.maxValue = 500.0
        
        rangeSeekSlider.selectedMinValue = 10.0
        rangeSeekSlider.selectedMaxValue = 500.0
        
        rangeSeekSlider.numberFormatter.numberStyle = .currency
        rangeSeekSlider.numberFormatter.locale = Locale(identifier: "en_EU")
        rangeSeekSlider.numberFormatter.maximumFractionDigits = 2
    }
}

// MARK: Utility
extension FriendsInterestViewController {
    
    func convertToArray(str: String) -> [String]? {
        
        let data = str.data(using: .utf8)
        
        do {
            return try JSONSerialization.jsonObject(with: data!, options: []) as? [String]
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
        
    }
}
