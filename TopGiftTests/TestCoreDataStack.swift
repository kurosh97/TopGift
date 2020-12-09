//
//  TestCoreDataStack.swift
//  TopGiftTests
//
//  Created by Micky on 27.11.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//

import XCTest
import CoreData
import TopGift
import Foundation

class TestCoreDataStack: CoreDataStack {
    override init() {
        super.init()
        
        // 1
        let persistentStoreDescription =
        NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        // 2
        let container = NSPersistentContainer(
            name: CoreDataStack.modelName,
            managedObjectModel: CoreDataStack.model)
        
        // 3
        container.persistentStoreDescriptions =
        [persistentStoreDescription]
        
        container.loadPersistentStores {
            _, error in
            if let error = error as NSError? {
                fatalError("Unresolver error \(error), \(error.userInfo)")
            }
        }
        
        storeContainer = container
    }
}
