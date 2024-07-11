//
//  User+CoreDataProperties.swift
//  HandyBudget
//
//  Created by Jadson on 11/07/2024.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var firebase_ID: String?
    @NSManaged public var name: String?
    @NSManaged public var wallet: Wallet?

}

extension User : Identifiable {

}
