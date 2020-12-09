//
//  RecentFriendService.swift
//  TopGift
//
//  Created by Micky on 27.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import Foundation
import CoreData

public final class RecentFriendService {
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
extension RecentFriendService {
    
    @discardableResult
    public func add(age: String?,
                    email: String?,
                    fullName: String?,
                    gender: String?,
                    homeTown: String?,
                    phoneNum: String?,
                    profileImage: Data?) -> RecentFriend {
        
        let recentFriend = RecentFriend(context: managedObjectContext)
        
        recentFriend.id = UUID()
        recentFriend.changedAt = Date()
        
        recentFriend.age = age
        recentFriend.email = email
        recentFriend.fullName = fullName
        recentFriend.gender = gender
        recentFriend.homeTown = homeTown
        recentFriend.phoneNum = phoneNum
        recentFriend.profileImage = profileImage
        
        coreDataStack.saveContext(managedObjectContext)
        
        return recentFriend
    }
    
    public func getRecentFriends() -> [RecentFriend]? {
        let recentFriendFetch: NSFetchRequest<RecentFriend>
            = RecentFriend.fetchRequest()
        do {
            let results = try managedObjectContext.fetch(recentFriendFetch)
            return results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return nil
    }
    
    @discardableResult
    public func update(_ report: RecentFriend) -> RecentFriend {
      coreDataStack.saveContext(managedObjectContext)
      return report
    }

    public func delete(_ report: RecentFriend) {
      managedObjectContext.delete(report)
      coreDataStack.saveContext(managedObjectContext)
    }
}

