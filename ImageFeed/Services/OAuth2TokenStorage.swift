//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    func removeToken() {
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
}
