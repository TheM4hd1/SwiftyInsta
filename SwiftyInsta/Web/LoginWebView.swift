//
//  LoginWebView.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/19/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

#if os(iOS)
import UIKit
import WebKit

// MARK: Views
@available(iOS 11, *)
public class LoginWebView: WKWebView, WKNavigationDelegate {
    /// Called when reaching the end of the login flow.
    ///  You should probably hide the `InstagramLoginWebView` and notify the user with an activity indicator.
    public var didReachEndOfLoginFlow: (() -> Void)?
    /// Called once the flow is completed.
    var completionHandler: ((Result<[HTTPCookie], Error>) -> Void)!
    
    // MARK: Init
    public init(frame: CGRect,
                configuration: WKWebViewConfiguration = .init(),
                didReachEndOfLoginFlow: (() -> Void)? = nil) {
        // update the process pool.
        let copy = configuration.copy() as! WKWebViewConfiguration
        copy.processPool = WKProcessPool()
        // init login.
        self.didReachEndOfLoginFlow = didReachEndOfLoginFlow
        super.init(frame: frame, configuration: copy)
        self.navigationDelegate = self
    }
        
    @available(*, unavailable, message: "use `init(frame:configuration:didReachEndOfLoginFlow:didSuccessfullyLogIn:completionHandler:)` instead.")
    private override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        fatalError("init(frame:, configuration:) has been removed")
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Log in
    func authenticate(completionHandler: @escaping (Result<[HTTPCookie], Error>) -> Void) {
        // update completion handler.
        self.completionHandler = completionHandler
        // wipe all cookies and wait to load.
        deleteAllCookies { [weak self] in
            guard let me = self else { return completionHandler(.failure(CustomErrors.weakReferenceReleased)) }
            let url = URL(string: "https://www.instagram.com/accounts/login/")!
            // in some iOS versions, use-agent needs to be different.
            // this use-agent works on iOS 11.4 and iOS 12.0+
            // but it won't work on lower versions.
            if #available(iOS 11.4, *) {
                me.customUserAgent = "(Linux; Android 5.0; iPhone Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Mobile Safari/537.36"
            } else {
                me.customUserAgent = "(Linux; Android 4.4.2; SCH-I545 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.111 Mobile Safari/537.36"
            }
            // load request.
            me.load(URLRequest(url: url))
        }
    }

    // MARK: Clean cookies
    private func fetchCookies() {
        configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] in
            self?.completionHandler?(.success($0))
        }
    }
    
    private func deleteAllCookies(completionHandler: @escaping () -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                modifiedSince: .distantPast,
                                                completionHandler: completionHandler)
    }
    
    // MARK: Navigation delegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView.url?.absoluteString == "https://www.instagram.com/" else { return }
        // notify user.
        didReachEndOfLoginFlow?()
        // fetch cookies.
        fetchCookies()
    }
}
#endif
