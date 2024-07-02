//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init () { }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
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
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let token = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(token.accessToken))
                } catch {
                    print("Function: \(#function), line \(#line) Failed to Decode OAuthTokenResponseBody")
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print("Function: \(#function), line \(#line) Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
