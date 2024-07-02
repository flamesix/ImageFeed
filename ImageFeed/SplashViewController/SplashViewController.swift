//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let logoImage: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "LaunchScreenLogo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    private let storage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
            switchToAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        let vc = TabBarViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func switchToAuthViewController() {
        let vc = AuthViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
        
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                self?.switchToTabBarController()
                self?.storage.token = token
            case .failure(let error):
                print("Function: \(#function), line \(#line) Error: (\(error.localizedDescription)")
                print(error.localizedDescription)
            }
        }
    }
}
