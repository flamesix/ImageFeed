//
//  Constants.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 01.06.2024.
//

import Foundation

enum Constants {
    static let likeActive = "likeActive"
    static let likeInactive = "likeInactive"
    
    static let accessKey = "tagOVdf_GPy4HD4NIATjnBFxi1YGkknt_P1AQUF49Jk"
    static let secretKey = "NZ1qRBPI1R7v1E5LcKyg2T-3Jd7vRdIysFbbkhYPnmo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let tokenURL = "https://unsplash.com/oauth/token"
}
