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

class DataController {
    static let shared = DataController()
    
    
    let baseURL = URL(string: "aaa")!
    let jsonDecoder = JSONDecoder()
    
    func fetchTransactions(for userID: String) {
        //'appendingPathComponent' will be deprecated in a future version of iOS: Use appending(path:directoryHint:) instead
        let transactionURL = baseURL.appendingPathComponent("\(userID)")
    }
    

    
    
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
                print(authData.user.email)
                var dict: Dictionary<String, Any> = [
                    "uid": authData.user.uid,
                    "email": authData.user.email,
                    "profileImageUrl": ""
                ]
                //create the reference to the storage on firebase
                let storageRef = Storage.storage().reference(forURL: "gs://budget-manager-75102.appspot.com")
                let storageProfileRef = storageRef.child("profilePicture").child(authData.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                storageProfileRef.putData(imageData,metadata: metadata) { storageMetadata, error in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    
                    //download the image to save on the dictionary
                    storageProfileRef.downloadURL { url, error in
                        if let metaImageUrl = url?.absoluteString {
                            dict["profileImageUrl"] = metaImageUrl
                            
                            Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dict) { error, ref in
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
        }
        
    }
    
    //create the user on the database (mysql)
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
    
    func updateUser(_ userID: String){
        
    }
    
    func updateTransaction(_ transactionID: Int){
        
    }
    
    func deleteTransaction(_ transactionID: Int){
        
    }
    
    
}
