//
//  PersonHistoryTableViewController.swift
//  TopGift
//
//  Created by iosdev on 9.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import CoreData

class RecentFriendsTableViewController: UITableViewController {
    
    @objc var people: [RecentFriend]?
    var selectedItem: RecentFriend?
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchRecentFriends()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchRecentFriends()
    }
    
    
    private func fetchRecentFriends() {
        // Fetch and save data from Core Data to display in the TableView
        
        let request = RecentFriend.fetchRequest() as NSFetchRequest<RecentFriend>
        
        let sort = NSSortDescriptor(key: #keyPath(RecentFriend.changedAt), ascending: false)
        
        request.sortDescriptors = [sort]
        
        do {
            
            self.people = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            fatalError("Failed to reload table view.")
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = people?[indexPath.row]
        return indexPath
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return people?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        let navigate = "RecentFriendsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: navigate , for: indexPath) as? RecentFriendsTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let p = self.people?[indexPath.row]
        
        cell.personsImage.image = UIImage(data: (p?.profileImage)!)
        
        cell.personsNameLabel.text = p?.fullName
        
        let homeTown = p?.homeTown ?? "No hometown found."
        if !homeTown.isEmpty {
            cell.personsAddressLabel.text = "🏠 \(homeTown)"
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    //     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? RecentFriendsViewController else {
            return
        }
        destinationVC.data = selectedItem
    }
}
