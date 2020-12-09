//
//  FriendDetailViewController.swift
//  TopGift
//
//  Created by Micky on 18.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import os.log


class FriendDetailViewController: UIViewController {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var friend: NewFriend?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var nameTextLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailTextLabel: UILabel!
    
    @IBOutlet weak var phoneTextLabel: UILabel!
    
    @IBOutlet weak var ageTextLabel: UILabel!
    
    @IBOutlet weak var homeNameLabel: UILabel!
    
    @IBOutlet weak var genderTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        commonInit()
        
        // Set Back button color
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 0.5, blue: 0.1, alpha: 1)
        
        //self.navigationBar.tintColor = [UIColor whiteColor]; //your color of what you want, I assume you want white based on your background color
        self.createRecentFriend()
    }
    
    private func commonInit() {
        
        guard let data = friend else {
            return
        }
        
        let notFoundText = NSLocalizedString("Value does not exist", comment: "If key value pair exists for friend")
        
        profileImage.image = UIImage(data: data.profileImage!)
        
        nameTextLabel.text = data.fullName ?? notFoundText
        
        emailTextLabel.text = data.email != "" ?  data.email : notFoundText
        
        phoneTextLabel.text = data.phoneNum != "" ? data.phoneNum : notFoundText
        
        ageTextLabel.text = data.age != ""
            ? data.age : notFoundText
        
        homeNameLabel.text = data.homeTown != "" ? data.homeTown : notFoundText
        
        genderTextLabel.text = data.gender != "" ? data.gender : notFoundText
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "EditFriend":
            guard let FriendEditViewController = segue.destination as? FriendEditViewController else {
                fatalError("Unexected destination: \(segue.destination)")
            }
            
            FriendEditViewController.friend = friend
            
        case "EditFriendInterests":
            guard let FriendsInterestViewController = segue.destination as? FriendsInterestViewController else {
                fatalError("Unexected destination: \(segue.destination)")
            }
            
            FriendsInterestViewController.friend = friend
        
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}

// MARK: Create Recently Viewed Friend
extension FriendDetailViewController {
    
    func create() {
        let recentFriend = RecentFriend(context: self.context)
        
        recentFriend.fullName = friend?.fullName
        
        recentFriend.id = friend?.id
        recentFriend.changedAt = friend?.changedAt
        
        recentFriend.profileImage = friend?.profileImage
        recentFriend.email = friend?.email
        recentFriend.phoneNum = friend?.phoneNum
        recentFriend.age = friend?.age
        recentFriend.homeTown = friend?.homeTown
        recentFriend.gender = friend?.gender
        
        
        do {
            try self.context.save()
        } catch {
            
        }
    }
    
    func createRecentFriend() {
        var recentFriends: [RecentFriend] = []
        
        do {
            recentFriends = try context.fetch(RecentFriend.fetchRequest())
        } catch {
            
        }
        
        let updateRecent = recentFriends.filter { recent in recent.id == friend?.id }
        
        let exists = updateRecent.isEmpty == false
        
        if exists {
            
            updateRecent[0].changedAt = Date()
            
            do {
                try self.context.save()
            } catch {
                
            }
        } else {
            create()
        }
    }
}
