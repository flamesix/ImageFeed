//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 14.06.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        
        tabBar.barTintColor = UIColor(rgb: 0x1A1B22)
        tabBar.tintColor = .ypWhite
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        let imagesListNVC = UINavigationController(rootViewController: imagesListVC)
        
        imagesListNVC.navigationBar.barTintColor = UIColor(rgb: 0x1A1B22)
        imagesListNVC.navigationBar.tintColor = .ypWhite
        
        imagesListNVC.tabBarItem = UITabBarItem(title: "",
                                                image: UIImage(named: "tab_editorial_active"),
                                                tag: 1)
        
        profileVC.tabBarItem = UITabBarItem(title: "",
                                            image: UIImage(named: "tab_profile_active"),
                                            tag: 2)
        
        setViewControllers([
            imagesListNVC, profileVC
        ], animated: true)
    }
}
