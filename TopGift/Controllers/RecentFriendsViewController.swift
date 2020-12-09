//
//  RecentFriendsViewController.swift
//  TopGift
//
//  Created by Micky on 11.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

/// FriendsInterestViewController.swift
/// TopGift
/// In here you can provide the app with a needed data and it provides you with a gift
class RecentFriendsViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var nameTextLabel: UILabel!
    
    @IBOutlet weak var addressTextLabel: UILabel!
    
    var data: RecentFriend?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        
        commonInit()
        // Do any additional setup after loading the view.
    }
    
    private func commonInit() {
        guard let data = data else { return }
        
        nameTextLabel.text = data.fullName
        
        if (data.profileImage != nil) {
            image.image = UIImage(data: data.profileImage!)
        } else {
            image.image = UIImage(named: "defaultPhoto")
        }
        
        let homeTown = data.homeTown ?? ""
        if !homeTown.isEmpty {
            addressTextLabel.text = "🏠 \(homeTown)"
        }
    }
}
