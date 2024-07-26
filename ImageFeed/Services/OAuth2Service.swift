//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init () { }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        UIBlockingProgressHUD.show()
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, any Error>) in
            switch result {
            case .success(let token):
                UIBlockingProgressHUD.dismiss()
                completion(.success(token.accessToken))
                
                self?.task = nil
                self?.lastCode = nil
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Function: \(#function), line \(#line) Failed to Decode OAuthTokenResponseBody")
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        var urlComponents = URLComponents(string: Constants.tokenURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        let url = urlComponents?.url
        
        guard let url else {
            print("Function: \(#function), line \(#line) Failed to get URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
