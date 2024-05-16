//
//  UserSettingsViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.


import UIKit
import ProgressHUD
import FirebaseAuth
import CoreData

class UserSettingsViewController: UIViewController {
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var firstNameTextField: CustomTxtField!
    @IBOutlet weak var lastNameTextField: CustomTxtField!
    @IBOutlet weak var emailTextField: CustomTxtField!
    @IBOutlet weak var phoneNumberTextField: CustomTxtField!
    @IBOutlet weak var passwordTextField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTextField: CustomTxtField!
    @IBOutlet weak var updateProfileButton: CustomButton!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    var userDetails: NSFetchedResultsController<User>?
    
    let manager = CoreDataStack.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        updateProfileButton.isHidden = true
        passwordTextField.isHidden = true
        confirmPasswordTextField.isHidden = true
        //createKeyboardDoneButton()
        disclaimerLabel.text = "⚠️ User profile will be available for editing in future updates ⚠️"
        userProfilePicture.layer.cornerRadius = 40
        userProfilePicture.clipsToBounds = true

    }

    func loadLabels(for user: User) {
        firstNameTextField.text = user.name
        lastNameTextField.text = user.surname
        emailTextField.text = user.email
        phoneNumberTextField.text = user.phone
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

}

extension UserSettingsViewController: NSFetchedResultsControllerDelegate {
    
    func loadUserData()  {
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
        self.userDetails = controller
        
        do {
            try controller.performFetch()
        } catch let error {
            ProgressHUD.failed("Error finding the user\n \(error)")
        }
        if userDetails?.fetchedObjects?.count == 0 {
            ProgressHUD.failed("Failed findind user")
        } else {
            if let user = userDetails?.fetchedObjects?.first {
                loadProfilePicture()
                loadLabels(for: user)
            }
        }
    }
}

//MARK: - Keyboard Settings
extension UserSettingsViewController {
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [lastNameTextField, firstNameTextField, emailTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}
