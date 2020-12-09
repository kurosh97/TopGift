//
//  FriendTableViewCell.swift
//  TopGift
//
//  Created by Micky on 10.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var homeName: UILabel!

    @IBOutlet weak var friendName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
