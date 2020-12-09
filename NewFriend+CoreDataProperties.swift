//
//  NewFriend+CoreDataProperties.swift
//  TopGift
//
//  Created by Micky on 3.12.2020.
//  Copyright © 2020 IOS-BOYS. All rights reserved.
//
//

import Foundation
import CoreData


extension NewFriend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewFriend> {
        return NSFetchRequest<NewFriend>(entityName: "NewFriend")
    }

    @NSManaged public var age: String?
    @NSManaged public var changedAt: Date?
    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var gender: String?
    @NSManaged public var homeTown: String?
    @NSManaged public var id: UUID?
    @NSManaged public var phoneNum: String?
    @NSManaged public var profileImage: Data?
    @NSManaged public var category: String?
    @NSManaged public var size: String?
    @NSManaged public var personality: String?
    @NSManaged public var minPrice: Double
    @NSManaged public var maxPrice: Double

}

extension NewFriend : Identifiable {

}
