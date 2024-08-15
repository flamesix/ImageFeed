//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 10.08.2024.
//

import Foundation
import Kingfisher

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapLogoffButton()
    func updateProfileDetails()
    func observe(placeholder: Placeholder)
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    private let logoutService = ProfileLogoutService.shared
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func didTapLogoffButton() {
        logoutService.logout()
    }
    
    private func updateAvatar(placeholder: Placeholder) {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        view?.profileImage.kf.setImage(with: url,
                                 placeholder: placeholder,
                                 options: [.processor(processor)])
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.nameLabel.text = profile.name
        view?.bioLabel.text = profile.bio
        view?.loginLabel.text = profile.loginName
    }
    
    func observe(placeholder: Placeholder) {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar(placeholder: placeholder)
            }
        updateAvatar(placeholder: placeholder)
    }
}
