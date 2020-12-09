//
//  OneProductService.swift
//  TopGift
//
//  Created by iosdev on 3.12.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import Foundation


/// OneProductService.swift
/// TopGift
///
/// This class is used for fetching one Item info from zalando API
class OneItemData {
    var itemUrl = ""
    ///fetches one item info from zalando
    ///fetches only product url
    func getZalandoItem (id: String, completion: @escaping () -> Void) {
        let url = URL(string: "https://api.zalando-wardrobe.de/api/marketplace/items/\(id)?with_deleted=true")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("9hC4HxmqRe7NG3HDPg9c6WEj", forHTTPHeaderField: "x-wardrobe-apikey")
        request.timeoutInterval = 20
        
        let session = URLSession.shared
        
        session.dataTask(with: request){ (data, response, error) in
            
            if let data = data {
                do {
                    
                    let decoder = JSONDecoder()
                    let itemdata = try decoder.decode(OneItemFeed.self, from: data)
                    self.itemUrl = itemdata.item.item.link_url

                    completion()
                    
                }catch {
                    print(error)
                }
            }
            
        }.resume()
    }
    
    struct OneItemFeed: Codable{
        var item: Item
        private enum CodingKeys:String, CodingKey {
            case item
        }
    }
    
    struct Item: Codable {
        var item: Item2
    }
    
    struct Item2: Codable{
        var link_url: String
        
        private enum CodingKeys:String, CodingKey {
            case link_url
        }
    }
    
}




