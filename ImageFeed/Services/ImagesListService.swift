//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 26.07.2024.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(_ photoResult: PhotoResult, date: ISO8601DateFormatter) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = date.date(from: photoResult.createdAt ?? "")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}

struct PhotoResult: Codable {
    let id: String
    let width: Double
    let height: Double
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
}

struct PhotoLike: Decodable {
    let photo: PhotoResult
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let storage = OAuth2TokenStorage()
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    private let urlSession = URLSession.shared
    private static let dateFormatter = ISO8601DateFormatter()
    
    private init() { }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeRequest(page: nextPage) else {
            print("Function: \(#function), line \(#line) Failed to get Request")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    if self.lastLoadedPage == nil {
                        self.lastLoadedPage = 1
                    } else {
                        self.lastLoadedPage! += 1
                    }
                    
                    let newPhotos = photoResults.map { Photo($0, date: ImagesListService.dateFormatter) }
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: nil)
                    
                case .failure(let error):
                    print("Function: \(#function), line \(#line) Failed to get PhotoResults")
                    print(error.localizedDescription)
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("Function: \(#function), line \(#line) Failed to get Request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoLike, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked.toggle()
                        completion(.success(()))
                    }
                case .failure(let error):
                    print("Function: \(#function), line \(#line) Failed to makeLikeRequest")
                    fatalError("error like: \(error)")
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/photos"
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents?.url else {
            print("Function: \(#function), line \(#line) Failed to get URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        
        var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/photos/\(photoId)/like"
        
        guard let url = urlComponents?.url else {
            print("Function: \(#function), line \(#line) Failed to get URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
