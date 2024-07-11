//
//  UserSettingsViewController.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 7/02/23.


import UIKit
import ProgressHUD
import FirebaseAuth
import CoreData
import FirebaseAnalytics

class UserSettingsViewController: UIViewController {
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var firstNameTextField: CustomTxtField!
    @IBOutlet weak var emailTextField: CustomTxtField!
    @IBOutlet weak var passwordTextField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTextField: CustomTxtField!
    @IBOutlet weak var updateProfileButton: CustomButton!
    @IBOutlet weak var deleteAccountButton: CustomButton!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    var user: NSFetchedResultsController<User>?
    var wallet: NSFetchedResultsController<Wallet>?
    var transaction: NSFetchedResultsController<Transaction>?
    
    
    let manager = CoreDataStack.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    let attributedString = NSAttributedString(
        string: NSLocalizedString("Delete Account", comment: ""),
        attributes:[
            NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20.0) ?? .systemFont(ofSize: 20.0),
            NSAttributedString.Key.foregroundColor: CustomColors.expenseLabelColor,
            NSAttributedString.Key.underlineStyle: 1.0
        ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        updateProfileButton.isHidden = true
        passwordTextField.isHidden = true
        confirmPasswordTextField.isHidden = true
        //createKeyboardDoneButton()
        disclaimerLabel.text = "⚠️ User profile will be available for editing in future updates ⚠️"
        deleteAccountButton.setAttributedTitle(attributedString, for: .normal)
        userProfilePicture.layer.cornerRadius = 40
        userProfilePicture.clipsToBounds = true

    }

    func loadLabels(for user: User) {
        firstNameTextField.text = user.name
        emailTextField.text = user.email
        ProgressHUD.dismiss()
    }
    
    func loadProfilePicture() {
        DataController.shared.loadPhoto { [weak self] customerImage in
            //safeImage is the check from userDefaults, if there's no image, the app will check on firebase
            if let safeImage = customerImage {
                self?.userProfilePicture.image = safeImage
            } else {
                DataController.shared.downloadPhotoFromFirebase { [weak self] userProfilePicture in
                    self?.userProfilePicture.image = userProfilePicture
                }
            }
        }
    }

    @IBAction func updateProfileButtonPressed(_ sender: CustomButton) {
    }
    

    @IBAction func deleteAccountButtonPressed(_ sender: CustomButton) {
        confirmationScreen()
    }
    
    func confirmationScreen() {
        let alertController = UIAlertController(
            title: "Delete Account?",
            message: "Are you sure you want to delete your account?\n Your data will be permanently deleted once the action is done",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Delete", style: .destructive) { action  in
            self.deleteUserAccount()
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func deleteUserAccount() {
        ProgressHUD.animate("Please Wait...", .barSweepToggle)
        deleteUserDataCoredata()
        Task {
            await deleteUserDataFirebase()
            redirectUserToLoginVC()
        }
    }
    
    func redirectUserToLoginVC(){

        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginViewController = storyboard.instantiateInitialViewController(),
               let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginViewController
            } else {
                ProgressHUD.failed("Failed to redirect to login screen")
            }
        } catch {
            ProgressHUD.failed("Failed to sign out")
        }
        
        ProgressHUD.succeed("Account sucessfully deleted!")
    }
    
    func deleteUserDataCoredata() {
        guard let user = user?.fetchedObjects?.first,
              let wallet = fetchWallet(),
              let transactions = fetchTransactions() else {
            ProgressHUD.failed("Failed to fetch user local data")
            return
        }
        
        for transaction in transactions {
            manager.context.delete(transaction)
        }
        manager.context.delete(wallet)
        manager.context.delete(user)
        manager.saveContext()
    }
    
    func deleteUserDataFirebase() async {
        guard let user = Auth.auth().currentUser else {
            ProgressHUD.failed("User not authenticated")
            return
        }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await DataController.shared.deletePhoto(uid: user.uid)
                }
                group.addTask {
                    try await DataController.shared.deleteUserProfile(uid: user.uid)
                }
                for try await _ in group { }
            }
            try await user.delete()
            Analytics.logEvent(A.userDeleted, parameters: nil)
            print("User account and data deleted successfully!")
        } catch {
            ProgressHUD.failed("An unexpected error ocurred, please try again later")
        }
    }
}

extension UserSettingsViewController: NSFetchedResultsControllerDelegate {
    
    func loadUserData() {
        ProgressHUD.animate("Loading User Details", .barSweepToggle)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "firebase_ID == %@", userID)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.user = controller
        
        do {
            try controller.performFetch()
        } catch let error {
            ProgressHUD.failed("Error finding the user\n \(error)")
        }
        if user?.fetchedObjects?.count == 0 {
            ProgressHUD.failed("Failed findind user")
        } else {
            if let user = user?.fetchedObjects?.first {
                loadProfilePicture()
                loadLabels(for: user)
            }
        }
    }
    
    
    func fetchWallet() -> Wallet? {
        guard let user = user?.fetchedObjects?.first else { return nil}
        
        let fetchRequest: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        self.wallet = controller
        do {
            try controller.performFetch()
            return controller.fetchedObjects?.first
        } catch let error {
            return nil
        }
    }
    
    func fetchTransactions() -> [Transaction]? {
        guard let wallet = wallet?.fetchedObjects?.first else { return nil}
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = NSPredicate(format: "wallet == %@", wallet)
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        self.transaction = controller
        
        do {
            try controller.performFetch()
            return controller.fetchedObjects
        } catch let error {
            return nil
        }
    }
}

//MARK: - Keyboard Settings
extension UserSettingsViewController {
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [firstNameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}
