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
    
    
    let baseURL = URL(string: "http://localhost:5105")!
    let jsonDecoder = JSONDecoder()
    let jsonEnconder = JSONEncoder()
    let session = URLSession(configuration: .default)
    
    //MARK: - Signin Function
    
    func signIn (withEmail email: String, password: String, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            onSucess()
        }
    }
    
//MARK: - creates user as they SignUp
    //create the user and save the profilePicute on firebase
    func signUp(withEmail email: String, password: String, image: UIImage?, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                ProgressHUD.showError(e.localizedDescription)
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
        
        storageProfileRef.putData(imageData, metadata: metadata) { storageMetadata, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            //download the image to save on the dictionary
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
    //MARK: - create the user on the database (mysql)
    
    func createCustomer(with customer: Customer, onSucess: @escaping (Customer) -> Void, onError: @escaping (String) -> Void) {
        let userURL = baseURL.appendingPathComponent("/customer")
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let body = try jsonEnconder.encode(customer)
            request.httpBody = body
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        onError("Failed to get data from the server")
                        return
                    }
                    do {
                        if response.statusCode == 200 {
                            let customer = try self.jsonDecoder.decode(Customer.self, from: data)
                            onSucess(customer)
                        } else {
                            let err = try self.jsonDecoder.decode(APIError.self, from: data)
                            onError(err.message)
                        }
                    } catch {
                        onError(error.localizedDescription)
                    }
                }
            }
            task.resume()
        } catch {
            onError(error.localizedDescription)
        }
    }
    
    //MARK: - Create the user's wallet
    
    func createUserWallet (for wallet: Wallet, onSucess: @escaping (Wallet) -> Void, onError: @escaping (String) -> Void) {
        let userWalletURL = baseURL.appendingPathComponent("/wallet")
        var request = URLRequest(url: userWalletURL)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let body = try jsonEnconder.encode(wallet)
            request.httpBody = body
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async { [self] in
                    if let error = error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        onError("Failed to get data from the server")
                        return
                    }
                    do {
                        if response.statusCode == 200 {
                            let wallet = try jsonDecoder.decode(Wallet.self, from: data)
                            onSucess(wallet)
                        } else {
                            let err = try jsonDecoder.decode(APIError.self, from: data)
                            onError(err.message)
                        }
                    } catch {
                        onError(error.localizedDescription)
                    }
                }
            }
            task.resume()
        } catch {
            onError(error.localizedDescription)
        }
    }
   
    //MARK: - CREATE THE TRANSACTION
    
    func createTransaction(transaction: Transaction, onSucess: @escaping (Transaction) -> Void, onError: @escaping (String) -> Void) {
        let transactionURL = baseURL.appendingPathComponent("/transaction)")
        var request = URLRequest(url: transactionURL)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let body = try jsonEnconder.encode(transaction)
            request.httpBody = body
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        onError(error.localizedDescription)
                        return
                    }
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        onError("Failed to get data from the server")
                        return
                    }
                    do {
                        if response.statusCode == 200 {
                            let transaction = try self.jsonDecoder.decode(Transaction.self, from: data)
                            onSucess(transaction)
                        } else {
                            let err = try self.jsonDecoder.decode(APIError.self, from: data)
                            onError(err.message)
                        }
                    } catch {
                        onError(error.localizedDescription)
                    }
                }
            }
            task.resume()
        } catch {
            onError(error.localizedDescription)
        }
    }
    
    //MARK: - FETCH TRANSACTIONS
    func fetchTransactions(type: Int, walletID: Int, onSuccess: @escaping (Transactions) -> Void, onError: @escaping (String) -> Void) {
        //'appendingPathComponent' will be deprecated in a future version of iOS: Use appending(path:directoryHint:) instead
        let transactionURL = baseURL.appendingPathComponent("/transaction/\(type)/\(walletID)")
        
        let task = session.dataTask(with: transactionURL) { data, response, error in
            DispatchQueue.main.async { [self] in
                if let error = error {
                    onError (error.localizedDescription)
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    onError("Invalid Data or response")
                    return
                }
                
                do {
                    if response.statusCode == 200 {
                        let transactions = try jsonDecoder.decode(Transactions.self, from: data)
                        onSuccess(transactions)
                    } else {
                        let error = try jsonDecoder.decode(APIError.self, from: data)
                        onError(error.message)
                    }
                } catch {
                    onError (error.localizedDescription)
                    print(String(describing: error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - FETCH CUSTOMER
    
    func fetchCustomer(_ userID: String, onSuccess: @escaping (Customer) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        let userURL = baseURL.appendingPathComponent("/customer/byid/\(userID)")
            let task = session.dataTask(with: userURL) { data, response, error in
                DispatchQueue.main.async  { [self] in
                    if let error = error {
                        onError(error.localizedDescription)
                        ProgressHUD.showError(error.localizedDescription)
                        print(String(describing: error))
                        return
                    }
                    guard let safeData = data else {
                        onError("Invalid Data")
                        return
                    }
                    do {
                        let customer = try jsonDecoder.decode(Customer.self, from: safeData)
                        onSuccess(customer)
                    } catch {
                        onError(error.localizedDescription)
                        ProgressHUD.showError(error.localizedDescription)
                    }
                }
            }
        task.resume()
    }
    
    //MARK: - FETCH WALLET
    
    func fetchUserWallet(for customerID: Int, onSuccess: @escaping (Wallet) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        let walletURL = baseURL.appendingPathComponent("/wallet/\(customerID)")
        let task = session.dataTask(with: walletURL) { data, response, error in
            DispatchQueue.main.async  { [self] in
                if let error = error {
                    onError(error.localizedDescription)
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                guard let safeData = data else {
                    onError("Invalid Data")
                    return
                }
                do {
                    let wallet = try jsonDecoder.decode(Wallet.self, from: safeData)
                    onSuccess(wallet)
                } catch {
                    onError(error.localizedDescription)
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    //MARK: - UPDATE USER
    
    func updateCustomer(_ customerID: String) {
        
    }
    //MARK: - UPDATE TRANSACTION
    
    func updateTransaction(_ transactionID: Int) {
        
    }
    //MARK: - DELETE TRANSACTION
    
    func deleteTransaction(_ transactionID: Int) {
        
    }
    
    
}
