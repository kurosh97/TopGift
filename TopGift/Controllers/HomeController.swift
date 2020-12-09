//
//  ViewController.swift
//  TopGift
//
//  Created by iosdev on 4.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import UIKit
import CoreData
import os.log


/// HomeController.swift
/// TopGift
///
/// HomeController class contains prepare and unwind functions for editing and viewing NewFriends
/// Use this method to get the greeting for the user. The person you specify don't affect the way user greet, just the first name, and last name will be used.
/// - Warning: The greeting is always in the caller localization.
/// - Throws:
///     - `MyError.invalidPerson`
///     if `person` is not known by the caller.
///     - `MyError.hardToPronounce`
///     if `person` name is longer than 20 characters.
/// - Parameter person: `User` you want to greet
/// - Returns: A greeting of the current `User`.
class HomeController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var selectedItem: NewFriend?
    
    var items: [NewFriend]?
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // TableView delegate setup
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        // Searchbar delegate setup
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        // Fetch the data
        self.fetchFriends()
    }
    
    private func fetchFriends() {
        // Fetch and save data from Core Data to display in the TableView
        
        do {
            try self.context.save()
        } catch {
            fatalError("Failed to fetch friends.")
        }
        
        do {
            let request = NewFriend.fetchRequest() as NSFetchRequest<NewFriend>
            
            let sort = NSSortDescriptor(key: #keyPath(NewFriend.changedAt), ascending: false)
            
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.friendsTableView.reloadData()
            }
            
        } catch {
            fatalError("Failed to reload table view.")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = items?[indexPath.row]
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            // Which person to remove
            let friendToRemove = self.items![indexPath.row]
            
            // Remove the person
            
            self.context.delete(friendToRemove)
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                
            }
            // Re-fetch the data
            self.fetchFriends()
            
        }
        
        // Delete button label
        action.accessibilityLabel = "deleteBtn"
        
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let friend = self.items?[indexPath.row]
            
        cell.friendName.text = friend?.fullName
        
        cell.homeName.text = friend?.homeTown
        
        cell.profileImage.image = UIImage(data: (friend?.profileImage)!)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        case "ShowProducts":
            os_log("Show products.", log: OSLog.default, type: .debug)
            
        case "AddNewFriend":
            os_log("Adding a new friend.", log: OSLog.default, type: .debug)
        
        case "ViewFriend":
            guard let addNewFriendController = segue.destination as? FriendDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedFriendCell = sender as? FriendTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = friendsTableView.indexPath(for: selectedFriendCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedFriend = items?[indexPath.row]
            addNewFriendController.friend = selectedFriend
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: Private functions
    
    @IBAction func unwindToFriendsList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? FriendEditViewController, let friend = sourceViewController.friend {
            
            if let selectedIndexPath = friendsTableView.indexPathForSelectedRow {
                // Update existing friend.
                items?[selectedIndexPath.row] = friend
                
                self.fetchFriends()
                
            } else {
                // Add a new friend.
                let newIndexPath = IndexPath(row: items?.count ?? 0, section: 0)
                
                items?.append(friend)
                
                friendsTableView.insertRows(at: [newIndexPath], with: .automatic)
                
                self.fetchFriends()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension HomeController: UISearchBarDelegate {
    
    func searchForFriends() {
        guard let searchText = searchBar.text else {
            return
        }
        
        do {
            let request = NewFriend.fetchRequest() as NSFetchRequest<NewFriend>
            
            // Filter NewFriend Core Data items by fullName
            if !searchText.isEmpty {
                let pred = NSPredicate(format: "fullName CONTAINS[cd] %@", searchText)
                request.predicate = pred
                
                self.items = try context.fetch(request)
                
                DispatchQueue.main.async {
                    self.friendsTableView.reloadData()
                }
            } else {
                self.fetchFriends()
            }
            
        } catch {
            fatalError("Error occurred when trying to filter NewFriends.")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        
        self.fetchFriends()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForFriends()
    }
}
