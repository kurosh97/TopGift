import Foundation
import UIKit


/// api_data.swift
/// TopGift
///
/// This class is used for fetching items from zalando API, uses callbacks to bring data back
///- Parameter completionBlock: call back function that provides the fetched items as parameter
class ApiData {
    private var categoryStrings = [String]()
    private var sizeStrings = [String]()
    public var maxPrice : Double = 200.0
    public var minPrice : Double = 0.0
    public var colorFilters = [Color]()
    private var loadingCallBack: (([Item]) -> Void)
    public var page = 1
    
    init(completionBlock: @escaping (([Item]) -> Void)) {
    self.loadingCallBack = completionBlock
    }
    
    ///set category before calling the zalandoItemFeed method
    /// - Parameter categorys: [String] Array for all the applied categorys
    func setCategorys(categorys: [String]) -> Void {
        for category in categorys {
            categoryStrings.append(parseCategory(categoryName: category))
        }
    }
    
    ///set size filters before calling the getZalandoItemFeed() method
    /// - Parameter sizes: All the wanted sizes that api filters
    func setSizes(sizes: [String]) -> Void {

        for size in sizes {
            sizeStrings.append(parseSize(size: size))
        }
    }
    
    ///fetches items from zalando and calls callback
    ///- Warning: apply filters before calling this.
    func getZalandoItemFeed ()-> Void {
            var items = [Item]()
            let url = URL(string: "https://api.zalando-wardrobe.de/api/marketplace/groups/webshop/all_items/search?page_size=40&page_number=\(page)&sort=created_at&sort_direction=desc&b2c=true&c2c=true")!
        
            let parameters: [String: Any] = [
                "sort": "latest",
                "categories": categoryStrings,
                "size_ids": sizeStrings,
                "min_price": minPrice,
                "max_price": maxPrice
            ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("9hC4HxmqRe7NG3HDPg9c6WEj", forHTTPHeaderField: "x-wardrobe-apikey")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else{
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 20
            let session = URLSession.shared
            session.dataTask(with: request){ (data, _, error) in

                if let data = data {
                
                    do {
                        let decoder = JSONDecoder()
                        let itemFeed = try decoder.decode(ItemFeed.self, from: data)
                        // parsing the items out of the item object
                        
                        for item in itemFeed.items {
                            let group = DispatchGroup()
                            group.enter()
                            DispatchQueue.global().async {
                                guard let imageUrl = URL(string: item.item.images?[0].url ?? "") else {
                                    return
                                }
                                let data = try? Data(contentsOf: imageUrl)
                                
                                var image = UIImage(named: "defaultPhoto")
                                
                                if let imageData = data {
                                    image = UIImage(data: imageData)
                                }

                                let averageColor = image?.averageColor
                                
                                if(self.colorFilters.count == 0){
                                    var item = item.item
                                    item.color = averageColor?.color()
                                    if(item.color != Color.none){
                                        items.append(item)
                                    }
                                }
                                else{
                                    if(self.colorFilters.contains(averageColor?.color(tolerance: 5) ?? Color.black)){
                                        var item = item.item
                                        item.color = averageColor?.color()
                                        items.append(item)
                                    }
                                }
                                group.leave()
                            }
                            group.wait()
                        }
                        self.loadingCallBack(items)
                    } catch {
                        print(error)
                    }
                        
                }
            }.resume()

        }
}

extension UIImage {
    var averageColor: UIColor {
        guard let inputImage = CIImage(image: self) else {return UIColor.black}

        
        let extentVector = CIVector(x: self.size.width/2.0, y: self.size.height/2.0, z: 60, w: 60)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else {return UIColor.black   }
        guard let outputImage = filter.outputImage else {  return UIColor.black}

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

enum Color {
    case red, orange, yellow, yellowGreen, green, greenCyan, cyan, cyanBlue, blue, blueMagenta, magenta, magentaRed,black,white,grey,none
}

extension UIColor {

    func color(tolerance: Int = 15) -> Color {
        precondition(0...15 ~= tolerance)
        guard let hsb = hsb else { return Color.none }
        if hsb.saturation == 0 { return Color.none }
        if hsb.brightness == 0 { return Color.none }
        if hsb.brightness > 0.92 && hsb.saturation < 0.5 {return .white}
        if hsb.saturation < 0.03{return .grey}
        if hsb.brightness < 0.23 {return .black}
        let hue = Int(hsb.hue * 360)
        switch hue {
        case 0 ... tolerance: return .red
        case 30 - tolerance ... 30 + tolerance: return .orange
        case 60 - tolerance ... 60 + tolerance: return .yellow
        case 90 - tolerance ... 90 + tolerance: return .yellowGreen
        case 120 - tolerance ... 120 + tolerance: return .green
        case 150 - tolerance ... 150 + tolerance: return .greenCyan
        case 180 - tolerance ... 180 + tolerance: return .cyan
        case 210 - tolerance ... 210 + tolerance: return .cyanBlue
        case 240 - tolerance ... 240 + tolerance: return .blue
        case 270 - tolerance ... 270 + tolerance: return .blueMagenta
        case 300 - tolerance ... 300 + tolerance: return .magenta
        case 330 - tolerance ... 330 + tolerance: return .magentaRed
        case 360 - tolerance ... 360 : return .red
        default: break
        }
        
        return Color.none
    }
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        return (hue, saturation, brightness, alpha)
    }
}

struct ItemFeed:Codable{
    var title: [Title]
    var items: [Items]
    
    private enum CodingKeys:String, CodingKey {
        case title
        case items
    }
}

struct Items: Codable {
    var item: Item
}

struct Item: Codable {
    var id: String
    var brand: String?
    var category: String?
    var size: String?
    var color: Color?
    var price: Price
    var images: [Image]?
    
    private enum CodingKeys:String, CodingKey {
        case id
        case brand
        case category
        case size
        case price
        case images
    }
}

struct Title: Codable {
    var lang: String
    var value: String?
}

struct Image: Codable {
    var id: String
    var url: String
    
}

struct Price: Codable {
    var amount: Double
    var currency: String?
}

func parseCategory(categoryName: String) -> String {
    
    // TODO: Parameter array
    
    switch categoryName {
    case "Shirts", "Paidat":
        return "9"
    case "Blouses", "Neuleet":
        return "1"
    case "Sweaters", "Villapaidat":
        return "2"
    case "Dresses", "Mekot":
        return "3"
    case "Pants", "Housut":
        return "5"
    case "Skirts", "Hame":
        return "4"
    case "Blazers", "Bleiseri":
        return "10"
    case "Jackets", "Takki":
        return "6"
    case "Shoes", "Kengät":
        return "8"
    case "Handbags", "Käsilaukut":
        return "7"
    case "Jumpsuits", "Haalari":
        return "11"
    default:
        return "0"
    }
}

func parseSize(size: String) -> String {
    
    switch size {
    case "XXXS":
        return "c30"
    case "XXS":
        return "c32"
    case "XS":
        return "c34"
    case "S":
        return "c36"
    case "M":
        return "c38"
    case "L":
        return "c40"
    case "XL":
        return "c42"
    case "XXL":
        return "c44"
    case "XXXL":
        return "c46"
    case "35":
        return "s35"
    case "35.5":
        return "s35.5"
    case "36":
        return "s36"
    case "36.5":
        return "s36.5"
    case "37":
        return "s37"
    case "37.5":
        return "s37.5"
    case "38":
        return "s38"
    case "38.5":
        return "s38.5"
    case "39":
        return "s39"
    case "39.5":
        return "s39.5"
    case "40":
        return "s40"
    case "40.5":
        return "s40.5"
    case "41":
        return "s41"
    case "41.5":
        return "s41.5"
    case "42":
        return "s42"
    case "42.5":
        return "s42.5"
    case "43":
        return "s43"
    case "43.5":
        return "s43.5"
    case "44":
        return "s44"
    case "44.5":
        return "s44.5"
    case "45":
        return "s45"
    case "45.5":
        return "s45.5"
    case "46":
        return "s46"
    default:
        return "0"
    }
    
}


