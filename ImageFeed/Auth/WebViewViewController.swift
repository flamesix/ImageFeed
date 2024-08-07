//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 29.06.2024.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private let progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progressTintColor = .ypBlack
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let webView: WKWebView = {
        let web = WKWebView()
        web.translatesAutoresizingMaskIntoConstraints = false
        return web
    }()
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadAuthView()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    private func loadAuthView()  {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Function: \(#function), line \(#line) Failed to get URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    
    private func configureUI() {
        webView.navigationDelegate = self
        view.addSubviews(progressBar, webView)
        view.backgroundColor = .ypWhite
        
        NSLayoutConstraint.activate([
            
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 2),
            
            webView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            
            return codeItem.value
            
        } else {
            return nil
        }
    }
}
