//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 13.07.2024.
//

import Foundation

struct UserResult: Codable {
    let profileImage: Image
}

struct Image: Codable {
    let small: String
}

final class ProfileImageService {
    
    enum ProfileImageServiceError: Error {
        case invalidRequest
    }
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private (set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage()
    
    private init() { }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeRequest(token: storage.token, username: username) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                self?.avatarURL = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage.small])
                
                self?.task = nil
            case .failure(let error):
                print("Function: \(#function), line \(#line) Failed to fetch ProfileResult")
                print(error.localizedDescription)
            }
        }
        self.task = task
        task.resume()
    }
    
    
    private func makeRequest(token: String?, username: String) -> URLRequest? {
        var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/users/\(username)"
        
        guard let url = urlComponents?.url,
              let token else {
            print("Function: \(#function), line \(#line) Failed to get URL or/and Token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
