//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 13.07.2024.
//

import Foundation

struct Profile {
    let username: String
    let bio: String
    let name: String
    var loginName: String {
        "@" + username
    }
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String
    let bio: String?
    let email: String
}

final class ProfileService {
    
    enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    static let shared = ProfileService()
    var profile: Profile?
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private init () { }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                guard let profile = self?.convertProfileResultToProfile(profileResult: profileResult) else {
                    print("Function: \(#function), line \(#line) Failed to Convert ProfileResult")
                    return
                }
                completion(.success(profile))
                
                self?.task = nil
                self?.lastToken = nil
            case .failure(let error):
                print("Function: \(#function), line \(#line) Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(token: String?) -> URLRequest? {
        var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = "/me"
        
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
    
    private func convertProfileResultToProfile(profileResult: ProfileResult) -> Profile {
        let profile = Profile(username: profileResult.username, bio: profileResult.bio ?? "", name: profileResult.name)
        return profile
    }
}
