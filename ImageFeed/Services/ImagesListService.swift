//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 26.07.2024.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
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
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() { }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else { return }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
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
                    
                    let newPhotos = photoResults.map { Photo($0, date: self.dateFormatter) }
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: nil)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("Function: \(#function), line \(#line) Failed to get Request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<PhotoLike, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhotoResult = PhotoResult(id: photo.id,
                                                         width: photo.size.width,
                                                         height: photo.size.height,
                                                         createdAt: photo.createdAt?.description,
                                                         description: photo.welcomeDescription,
                                                         likedByUser: !photo.isLiked,
                                                         urls: UrlsResult(full: photo.largeImageURL,
                                                                          thumb: photo.thumbImageURL)
                                                         )
                        let newPhoto = Photo(newPhotoResult, date: self.dateFormatter)
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                    
                case .failure(let error):
                    print("Function: \(#function), line \(#line) Failed to makeLikeRequest")
                    fatalError("error like: \(error)")
                }
            }
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
