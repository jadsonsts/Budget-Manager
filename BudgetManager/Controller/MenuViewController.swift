//
//  MenuViewController.swift
//  BudgetManager
//
//  Created by Jadson on 3/12/23.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var userSettingsButton: UIButton!
    @IBOutlet weak var walletsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonUI()
    }
    

    func setupButtonUI() {
        
        setupButton(userSettingsButton, title: "User Settings", imageName: "person.circle" , background: .clear)
        setupButton(walletsButton, title: "Wallets", imageName: "wallet.pass", background: .clear)
        setupButton(aboutButton, title: "About", imageName: "info.circle", background: .clear)
        setupButton(logoutButton, title: "Logout", imageName: "power.circle", background: .clear)
        
    }
    
    func setupButton(_ button: UIButton, title: String, imageName: String,  background: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 22)
        button.setTitleColor(CustomColors.greenColor, for: .normal)
        button.setTitleColor(CustomColors.labelColor, for: .selected)
        button.backgroundColor = background
        if let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: -5, bottom: 12, right: 10)
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        confirmationScreen()
    }
    
    func confirmationScreen() {
        let alertController = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { action  in
            self.logout()
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    func logout(){
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil) 
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginWithEmailViewController") as? LoginWithEmailViewController,
               let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginViewController
            }
            //navigationController?.popToRootViewController(animated: true)
        } catch let logoutError as NSError {
            ProgressHUD.showError(logoutError as? String)
        }
    }

}
