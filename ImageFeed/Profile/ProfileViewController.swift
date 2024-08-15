//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 13.06.2024.
//

import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    var profileImage: UIImageView { get }
    var nameLabel: UILabel { get }
    var bioLabel: UILabel { get }
    var loginLabel: UILabel { get }
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 35
        image.clipsToBounds = true
        image.image = UIImage(named: "profileImage")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0xAEAFB4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoffButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "logoffButton"
        button.setImage(UIImage(named: "logoffButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var presenter: ProfileViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.updateProfileDetails()
        presenter?.observe(placeholder: UIImage(named: "placeholder.jpeg") ?? UIImage())
    }
    
    @objc private func didTapLogoffButton() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let alertYes = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.didTapLogoffButton()
            let vc = SplashViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let alertNo = UIAlertAction(title: "Нет", style: .default)
        [alertYes, alertNo].forEach { alertController.addAction($0) }
        
        present(alertController, animated: true)
        
    }
    
    private func configureUI() {
        presenter?.view = self
        
        view.backgroundColor = .ypBlack
        view.addSubviews(profileImage, nameLabel, loginLabel, bioLabel, logoffButton)
        
        logoffButton.addTarget(self, action: #selector(didTapLogoffButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            logoffButton.widthAnchor.constraint(equalToConstant: 24),
            logoffButton.heightAnchor.constraint(equalToConstant: 24),
            logoffButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoffButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            bioLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
    }
}
