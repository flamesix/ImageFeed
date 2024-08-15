//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Юрий Гриневич on 14.08.2024.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        let imagesListVC = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        imagesListVC.presenter = presenter
        presenter.view = imagesListVC
        
        _ = imagesListVC.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplay(for indexPath: IndexPath) {
        
    }
    
    func imageListCellDidTapLike(_ cell: ImageFeed.ImagesListCell, indexPath: IndexPath) {
        
    }
    
    func updateTableViewAnimated() {
        
    }
}
