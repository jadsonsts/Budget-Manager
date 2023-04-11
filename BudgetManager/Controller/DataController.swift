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

let REF_USER = "users"
let STORAGE_PROFILE = "profilePicture"
let URL_STORAGE_ROOT = "gs://budget-manager-75102.appspot.com"
let UID = "uid"
let EMAIL = "email"
let PROFILE_IMAGE_URL = "profileImageUrl"
let CONTENT_TYPE = "image/jpg"

class DataController {
    static let shared = DataController()
    
    
    let baseURL = URL(string: "aaa")!
    let jsonDecoder = JSONDecoder()
    
    
//MARK: - creates user as they SignUp
    
    //create the user and save the profilePicute on firebase
    func signUp(withEmail email: String, password: String, image: UIImage?, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e.localizedDescription) //CREATE POPUP WITH THE ERROR
                return
            }
            if let authData = authResult {
               // print(authData.user.email)
                var dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email,
                    PROFILE_IMAGE_URL: ""
                ]
                //create the reference to the storage on firebase
                let storageRef = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
                let storageProfileRef = storageRef.child(STORAGE_PROFILE).child(authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = CONTENT_TYPE
                
                self.savePhoto(uid: authData.user.uid, imageData: imageData, metadata: metadata, storageProfileRef: storageProfileRef, dict: dict) {
                    onSucess()
                } onError: { errorMessage in
                    onError(errorMessage)
                }
            }
        }
    }
    
    //MARK: - FIREBASE STORAGE SERVICE
    
    func savePhoto(uid: String, imageData: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        storageProfileRef.putData(imageData,metadata: metadata) { storageMetadata, error in
            if error != nil {
                //print(error?.localizedDescription)
                onError(error!.localizedDescription)
                return
            }
            
            //download the image to save on the dictionary
            storageProfileRef.downloadURL { url, error in
                if let metaImageUrl = url?.absoluteString {
                    
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
    
    //MARK: - create the user on the database (mysql)
    
    func createUser(with userID: String, completion: @escaping (String?) -> Void) {
        let userURL = baseURL.appendingPathComponent("user:\(userID)")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        request.setValue("", forHTTPHeaderField: "")
        let data: [String: String] = ["User": userID]
        let jsonEnconder = JSONEncoder()
        let jsonData = try? jsonEnconder.encode(data)
        
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let user = try? self.jsonDecoder.decode(Customer.self, from: data) {
                completion(user.name)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
   
    //MARK: - CREATE THE TRANSACTION
    
    func createTransaction(for userID: String, completion: @escaping (String?) -> Void) {
        let transactionURL = baseURL.appendingPathComponent("user:\(userID)")
        
        var request = URLRequest(url: transactionURL)
        request.httpMethod = "POST"
        request.setValue("", forHTTPHeaderField: "")
        let data: [String: String] = ["User": userID]
        let jsonEnconder = JSONEncoder()
        let jsonData = try? jsonEnconder.encode(data)
        
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data, let transaction = try? self.jsonDecoder.decode(Transactions.self, from: data) {
                completion(transaction.reference)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    //MARK: - FETCH TRANSACTIONS
    func fetchTransactions(for userID: String) {
        //'appendingPathComponent' will be deprecated in a future version of iOS: Use appending(path:directoryHint:) instead
        let transactionURL = baseURL.appendingPathComponent("\(userID)")
    }
    
    //MARK: - UPDATE THE USER
    
    func updateUser(_ userID: String){
        
    }
    //MARK: - UPDATE TRANSACTION
    
    func updateTransaction(_ transactionID: Int){
        
    }
    //MARK: - DELETE TRANSACTION
    
    func deleteTransaction(_ transactionID: Int){
        
    }
    
    
}
