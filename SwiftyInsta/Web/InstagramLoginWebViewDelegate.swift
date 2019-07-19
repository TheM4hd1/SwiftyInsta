//
//  InstagramLoginWebView.swift
//  SwiftyInsta
//
//  Created by Sehmus GOKCE on 15.04.2019. (freeman4706@github)
//  Copyright © 2019 Mahdi. All rights reserved.
//

import UIKit
import WebKit

@available(iOS 11, *)
public protocol InstagramLoginWebViewDelegate {
    func userLoggedSuccessfully()
    func webViewFinishedToLoadUser(sessionCache : SessionCache, handler: APIHandlerProtocol)
}

@available(iOS 11, *)
public class InstagramLoginWebView: WKWebView, WKNavigationDelegate {
    public var redirectCompleted: (() -> ())?
    public var loginDelegate : InstagramLoginWebViewDelegate?

    // MARK: Init
    public convenience init(frame: CGRect) {
        self.init(frame: frame, configuration: .init())
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        // update the process pool.
        let copy = configuration.copy() as! WKWebViewConfiguration
        copy.processPool = WKProcessPool()
        // init login view.
        super.init(frame: frame, configuration: copy)
        navigationDelegate = self
    }
    
    @available(*, unavailable, message: "use `init(frame:, configuration:)` instead.")
    public init(frame: CGRect, configurationBlock: ((WKWebViewConfiguration) -> Void)? = nil) {
        fatalError("init(frame:, configurationBlock:) has been removed")
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Log in
    public func loadInstagramLogin() {
        // wipe all cookies and wait to load.
        deleteAllCookies { [weak self] in self?.requestLogIn() }
    }
    
    private func requestLogIn() {
        let urlString = "https://www.instagram.com/accounts/login/"
        
        // in some iOS versions, use-agent needs to be different.
        // this use-agent works on iOS 11.4 and iOS 12.0+
        // but it won't work on lower versions.
        if #available(iOS 12.0, *) {
            self.customUserAgent = "(Linux; Android 5.0; iPhone Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Mobile Safari/537.36"
        } else if #available(iOS 11.4, *) {
            self.customUserAgent = "(Linux; Android 5.0; iPhone Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Mobile Safari/537.36"
            //self.customUserAgent = "(Linux; Android 4.4.2; SCH-I545 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.111 Mobile Safari/537.36"
        } else {
            self.customUserAgent = "(Linux; Android 4.4.2; SCH-I545 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.111 Mobile Safari/537.36"
        }
        
        self.load(URLRequest(url: URL(string: urlString)!))
    }
    
    public func isUserLoggedIn(instagramCookies : [HTTPCookie]?) {
        // check for cookies.
        guard let cookies = instagramCookies else { return }
        let filtered = cookies.filter { $0.name == "ds_user_id" || $0.name == "csrftoken" }
        guard filtered.count == 2 else { return }
        
        // deal with log in.
        let session = URLSession(configuration: .default)
        let user = SessionStorage.create(username: "username", password: "password")
        let handler = try! APIBuilder()
            .createBuilder()
            .setHttpHandler(urlSession: session)
            .setRequestDelay(delay: .default)
            .setUser(user: user)
            .build()
        
        let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!,
                                             device: HandlerSettings.shared.device!,
                                             requestMessage: HandlerSettings.shared.request!,
                                             cookies: cookies.toCookieData(),
                                             isUserAuthenticated: true)
        try? handler.login(cache: sessionCache) { _ in }
        // notify delegate if `!= nil`.
        loginDelegate?.userLoggedSuccessfully()
        // obtain current user.
        try? handler.getCurrentUser { [weak self] in
            guard $0.isSucceeded else { return }
            // obtain current user.
            let currentUser = $0.value?.user
            let shortUserModel = UserShortModel(isVerified: currentUser?.isVerified, isPrivate: currentUser?.isPrivate, pk: currentUser?.pk, profilePicUrl: currentUser?.profilePicUrl, profilePicId: nil, username: currentUser?.username, fullName: currentUser?.fullName, name: currentUser?.fullName, address: nil, shortName: nil, lng: nil, lat: nil, externalSource: nil, facebookPlacesId: nil, city: nil, biography: currentUser?.biography)
            
            HandlerSettings.shared.user!.loggedInUser = shortUserModel
            HandlerSettings.shared.user?.username = shortUserModel.username!
            HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
            HandlerSettings.shared.user?.csrfToken = filtered.first(where: { $0.name == "csrftoken" })!.value
            
            let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)
            // notify delegate if `!= nil`.
            self?.loginDelegate?.webViewFinishedToLoadUser(sessionCache: sessionCache, handler: handler)
        }
    }

    // MARK: Clean cookies
    private func fetchCookies() {
        configuration.websiteDataStore.httpCookieStore.getAllCookies {
            let instagramCookies = $0.getInstagramCookies()
            self.isUserLoggedIn(instagramCookies: instagramCookies)
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
        print("URL of Finished::::" + webView.url!.absoluteString)
        
        if webView.url!.absoluteString == "https://www.instagram.com/" {
            redirectCompleted?()
        }
        self.fetchCookies()
    }
}
