//
//  WalletPersistenceManager.swift
//  HandyBudget
//
//  Created by Jadson on 19/08/2024.
//

import UIKit
import ProgressHUD


protocol WalletDataPersistable {
    func save()
}

struct WalletDataPersistence {
    let persistence: WalletDataPersistable
    
    func save() {
        persistence.save()
    }
}

struct WalletCoreDataPersistence: WalletDataPersistable {
    
    let amount: Double
    let walletName: String
    let user: User
    
    func save() {
        let manager = CoreDataStack.shared
        
        let wallet = Wallet(context: manager.context)
        
        wallet.amount = amount
        wallet.name = walletName
        wallet.user = user //User.init(context: manager.context) //?
        
        manager.saveContext()
    }
}
