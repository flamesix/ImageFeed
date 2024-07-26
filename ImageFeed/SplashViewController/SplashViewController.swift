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
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
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
            fetchOAuthToken(code, vc)
    }
    
    private func fetchOAuthToken(_ code: String, _ vc: AuthViewController) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                self?.storage.token = token
                self?.fetchProfile(token)
            case .failure(let error):
                print("Function: \(#function), line \(#line) Error: (\(error.localizedDescription)")
                print(error.localizedDescription)
                
                let alert = UIAlertController(title: "Что-то пошло не так", message: "Не удалось войти в систему", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                vc.present(alert, animated: true)
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                self?.profileService.profile = profile
                self?.profileImageService.fetchProfileImageURL(username: profile.username, { result in
                    switch result {
                    case .success(let imageURL):
                        print("IMAGE URL: \(imageURL)")
                    case .failure(let error):
                        print("Function: \(#function), line \(#line) Unable to fetch ProfileImageURL \(error.localizedDescription)")
                    }
                })
                self?.switchToTabBarController()
            case .failure(let error):
                print("Function: \(#function), line \(#line) Unable to fetch Profile \(error.localizedDescription)")
                break
            }
        }
    }
}
