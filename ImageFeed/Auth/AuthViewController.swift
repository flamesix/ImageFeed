//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let logoImage: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "auth_screen_logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @objc private func didTapLoginButton() {
        let vc = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        vc.presenter = webViewPresenter
        webViewPresenter.view = vc
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = .ypBlack
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        view.addSubviews(logoImage, loginButton)
        configureBackButton()
        
        NSLayoutConstraint.activate([
            
            logoImage.widthAnchor.constraint(equalToConstant: 60),
            logoImage.heightAnchor.constraint(equalToConstant: 60),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "chevron.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "chevron.backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
