//
//  DataController.swift
//  BudgetManager
//
//  Created by Jadson on 27/02/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import ProgressHUD


let REF_USER = "users"
let STORAGE_PROFILE = "profilePicture"
let URL_STORAGE_ROOT = "gs://budget-manager-75102.appspot.com"
let UID = "uid"
let EMAIL = "email"
let PROFILE_IMAGE_URL = "profileImageUrl"
let CONTENT_TYPE = "image/jpg"
let USER_DEFAULTS_IMG_URL = "imageURL"

class DataController {
    static let shared = DataController()
    
    //references for the category methods
    let databaseRef = Database.database().reference()
    let CATEGORY_REF = "category"
    
    //MARK: - FIREBASE SIGNIN METHOD
    func signIn (withEmail email: String, password: String, onSucess: @escaping(_ result: AuthDataResult?) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            onSucess(authResult)
        }
    }

    
    //MARK: - creates user as they SignUp
    //create the user and save the profilePicute on firebase
    func signUp(withEmail email: String, password: String, image: UIImage?, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let e = error {
                ProgressHUD.failed(e.localizedDescription)
                return
            }
            if let authData = authResult {
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email,
                    PROFILE_IMAGE_URL: ""
                ]
                //create the reference to the storage on firebase
                let storageRef = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
                let storageProfileRef = storageRef.child(STORAGE_PROFILE).child(authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = CONTENT_TYPE
                
                self?.savePhoto(uid: authData.user.uid, imageData: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict) {
                    onSucess()
                } onError: { errorMessage in
                    onError(errorMessage)
                }
            }
        }
    }
    
    //MARK: - FIREBASE STORAGE SERVICE
    
    // method to download the user's profile picture from Firebase Storage
    func downloadPhotoFromFirebase(completion: @escaping (UIImage?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        // Reference to the storage on Firebase
        let storageRef = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
        let storageProfileRef = storageRef.child(STORAGE_PROFILE).child(uid)
        
        storageProfileRef.downloadURL { url, error in
            guard let imageUrl = url, error == nil else {
                completion(nil)
                return
            }
            
            //add the image to the user defaults
            let metaImageUrl = imageUrl.absoluteString
            UserDefaults.standard.set(metaImageUrl, forKey: USER_DEFAULTS_IMG_URL)

            //get the image data to pass in
            let task = URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                let profilePicture = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(profilePicture)
                }
            }
            task.resume()
        }
        
    }
    
    func savePhoto(uid: String, imageData: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        storageProfileRef.putData(imageData, metadata: metadata) { storageMetadata, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            //download the image to save in the dictionary
            storageProfileRef.downloadURL { url, error in
                if let metaImageUrl = url?.absoluteString {
                    
                    //add the image url on UserDefautls
                    UserDefaults.standard.set(metaImageUrl, forKey: USER_DEFAULTS_IMG_URL)
                    
                    //change into firebase
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                    var dictTemp = dict
                    dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                    
                    Database.database().reference().child(REF_USER).child(uid).updateChildValues(dictTemp) { error, ref in
                        if error == nil {
                            onSucess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func loadPhoto(completion: @escaping (UIImage?) -> Void) {
        guard let urlString = UserDefaults.standard.value(forKey: USER_DEFAULTS_IMG_URL) as? String, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let profilePicture = UIImage(data: data)
            DispatchQueue.main.async {
                completion(profilePicture)
            }
        }
        task.resume()
    }
    
    //MARK: - FIREBASE FETCHING CATEGORIES
    
    func fetchCategories(onSuccess: @escaping (Category) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        databaseRef.child(CATEGORY_REF).observeSingleEvent(of: .value) { snapshot  in
            guard let snapshotValue = snapshot.value as? [[String: Any]] else {
                ProgressHUD.failed("Unable to fetch categories")
                return
            }
            let category = snapshotValue.map { item in
                return CategoryElement(categoryID: item["id"] as? Int32 ?? 0,
                                       categoryName: item["name"] as? String ?? "",
                                       iconName: item["iconName"] as? String ?? "",
                                       color: item["color"] as? String ?? "")
            }
            onSuccess(category)
        } withCancel: { error in
            onError(error.localizedDescription)
        }
    }
    
    func fetchCategoryById(categoryID: Int32, onSuccess: @escaping (CategoryElement) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        databaseRef.child(CATEGORY_REF).child("\(categoryID)").observeSingleEvent(of: .value) { snapshot in
            guard let snapshotValue = snapshot.value as? [String: Any] else {
                ProgressHUD.failed("Unable to fetch category details")
                return
            }
            if let categoryID = snapshotValue["id"] as? Int32,
               let categoryName = snapshotValue["name"] as? String,
               let iconName = snapshotValue["iconName"] as? String,
               let color = snapshotValue["color"] as? String {
                let category = CategoryElement(categoryID: categoryID,
                                               categoryName: categoryName,
                                               iconName: iconName,
                                               color: color)
                onSuccess(category)
            } else {
                onError("Invalid category data")
            }
        } withCancel: { error in
            onError(error.localizedDescription)
        }
    }
}
