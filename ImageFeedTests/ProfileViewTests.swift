//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Юрий Гриневич on 14.08.2024.
//

@testable import ImageFeed
import XCTest
import Kingfisher

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsUpdateProfileDetailsCalled() {
        let profileViewVC = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewVC.presenter = presenter
        presenter.view = profileViewVC
        
        _ = profileViewVC.view
        
        XCTAssertTrue(presenter.updateProfileDetailsCalled)
        XCTAssertTrue(presenter.observeCalled)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var updateProfileDetailsCalled: Bool = false
    var observeCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func didTapLogoffButton() {
        
    }
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }
    
    func observe(placeholder: any Kingfisher.Placeholder) {
        observeCalled = true
    }
}
