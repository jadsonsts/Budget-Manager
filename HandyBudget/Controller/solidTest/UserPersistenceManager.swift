//
//  UserPersistenceManager.swift
//  HandyBudget
//
//  Created by Jadson on 19/08/2024.
//

import UIKit
import ProgressHUD

protocol UserDataPersistable {
    func save(userPersistence: UserDataFirebase)
}

struct UserDataPersistence {
    let persistence: UserDataPersistable
    
    func save(user: UserDataFirebase) {
        persistence.save(userPersistence: user)
    }
}

struct UserCoreDataPersistence: UserDataPersistable {
    
    func save(userPersistence: UserDataFirebase) {
        
        let manager = CoreDataStack.shared
        let user = User(context: manager.context)
        
        user.name = userPersistence.name
        user.email = userPersistence.email
        user.firebase_ID = userPersistence.userID
        
        manager.saveContext()
    }
}
