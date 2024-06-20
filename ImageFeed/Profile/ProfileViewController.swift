//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 13.06.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "profileImage")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(rgb: 0xAEAFB4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
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
        button.setImage(UIImage(named: "logoffButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    @objc private func didTapLogoffButton() {
        print("didTapLogoffButton")
    }
    
    private func configureUI() {
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
