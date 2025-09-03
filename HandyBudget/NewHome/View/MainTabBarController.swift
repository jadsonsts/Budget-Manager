//
//  MainTabBarController.swift
//  HandyBudget
//
//  Created by Jadson on 03/09/2025.
//


import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let homeVC = NewHomeViewController()
        
        let settingsVC = UIViewController() // change to the current ViewController (UserSettingsVC)
        settingsVC.view.backgroundColor = .systemGray6

        let homeNav = UINavigationController(rootViewController: homeVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)

        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings", //change back to menu?
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gearshape.fill") //square.grid.2x2
        )

        viewControllers = [homeNav, settingsNav]

        tabBar.tintColor = CustomColors.greenColor
        tabBar.unselectedItemTintColor = CustomColors.labelColor
//        tabBar.layer.cornerRadius = 40
//        tabBar.backgroundColor = CustomColors.greenColor
    }
}
