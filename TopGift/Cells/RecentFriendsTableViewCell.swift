//
//  PersonHistoryTableViewCell.swift
//  TopGift
//
//  Created by iosdev on 9.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

class RecentFriendsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var personsImage: UIImageView!
    @IBOutlet weak var personsNameLabel: UILabel!
    @IBOutlet weak var personsAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
