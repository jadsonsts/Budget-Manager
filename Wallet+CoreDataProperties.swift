//
//  Wallet+CoreDataProperties.swift
//  
//
//  Created by Jadson on 19/04/2024.
//
//

import Foundation
import CoreData


extension Wallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }

    @NSManaged public var amount: Double
    @NSManaged public var name: String?
    @NSManaged public var transaction: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for transaction
extension Wallet {

    @objc(addTransactionObject:)
    @NSManaged public func addToTransaction(_ value: Transaction)

    @objc(removeTransactionObject:)
    @NSManaged public func removeFromTransaction(_ value: Transaction)

    @objc(addTransaction:)
    @NSManaged public func addToTransaction(_ values: NSSet)

    @objc(removeTransaction:)
    @NSManaged public func removeFromTransaction(_ values: NSSet)

}
