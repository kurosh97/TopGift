//
//  NewFriendService.swift
//  TopGift
//
//  Created by Micky on 27.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import Foundation
import CoreData

public final class NewFriendService {
    // MARK: - Properties
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack
    
    // MARK: - Initializers
    public init(managedObjectContext:
                    NSManagedObjectContext, coreDataStack:
                        CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}

// MARK: - Public
extension NewFriendService {
    
    @discardableResult
    public func add(age: String?,
                    email: String?,
                    fullName: String?,
                    gender: String?,
                    homeTown: String?,
                    phoneNum: String?,
                    profileImage: Data?) -> NewFriend {
        
        let newFriend = NewFriend(context: managedObjectContext)
        
        newFriend.id = UUID()
        newFriend.changedAt = Date()
        
        newFriend.age = age
        newFriend.email = email
        newFriend.fullName = fullName
        newFriend.gender = gender
        newFriend.homeTown = homeTown
        newFriend.phoneNum = phoneNum
        newFriend.profileImage = profileImage
        
        coreDataStack.saveContext(managedObjectContext)
        
        return newFriend
    }
    
    public func getNewFriends() -> [NewFriend]? {
        let newFriendFetch: NSFetchRequest<NewFriend>
            = NewFriend.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(newFriendFetch)
            return results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return nil
    }
    
    @discardableResult
    public func update(_ report: NewFriend) -> NewFriend {
      coreDataStack.saveContext(managedObjectContext)
      return report
    }

    public func delete(_ report: NewFriend) {
      managedObjectContext.delete(report)
      coreDataStack.saveContext(managedObjectContext)
    }
}

