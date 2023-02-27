//
//  DataController.swift
//  BudgetManager
//
//  Created by Jadson on 27/02/23.
//

import Foundation
import UIKit

class DataController {
    static let shared = DataController()
    
    
    let baseURL = URL(string: "")!
    let jsonDecoder = JSONDecoder()
    
    func fetchAllTransactions(for userID: String) {
        //'appendingPathComponent' will be deprecated in a future version of iOS: Use appending(path:directoryHint:) instead
        let transactionURL = baseURL.appendingPathComponent("\(userID)")
    }
    
    
//MARK: - creates user as they SignUp
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
    
    
}
