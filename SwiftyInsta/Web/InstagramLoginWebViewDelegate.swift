//
//  InstagramLoginWebView.swift
//  SwiftyInsta
//
//  Created by Sehmus GOKCE on 15.04.2019. (freeman4706@github)
//  Copyright © 2019 Mahdi. All rights reserved.
//

import UIKit
import WebKit

@available(*, deprecated, message: "use `InstagramLoginWebViewProtocol` closure properties instead.")
public protocol InstagramLoginWebViewDelegate: class {
    func userLoggedSuccessfully()
    func webViewFinishedToLoadUser(sessionCache : SessionCache, handler: APIHandlerProtocol)
}

public protocol InstagramLoginWebViewProtocol: UIView {
    var didReachEndOfLoginFlow: (() -> Void)? { get }
    var didSuccessfullyLogIn: (() -> Void)? { get }
    var completionHandler: ((_ sessionCache: SessionCache, _ handler: APIHandlerProtocol) -> Void)! { get }
    
    func loadInstagramLogin()
}

// MARK: Views
@available(iOS 11, *)
public class InstagramLoginWebView: WKWebView, WKNavigationDelegate, InstagramLoginWebViewProtocol {
    @available(*, deprecated, message: "use `didReachEndOfLoginFlow` instead.")
    /// Called when reaching the end of the login flow. Deprecated. Use `didReachEndOfLoginFlow` instead.
    public var redirectCompleted: (() -> ())? {
        get { return didReachEndOfLoginFlow }
        set { didReachEndOfLoginFlow = newValue }
    }
    /// Called when reaching the end of the login flow.
    ///  You should probably hide the `InstagramLoginWebView` and notify the user with an activity indicator.
    public var didReachEndOfLoginFlow: (() -> Void)?
    /// Called when the user has successfully logged in, in order to migrate from a previously logged acccount.
    public var didSuccessfullyLogIn: (() -> Void)?
    /// Retrieve session cache and handler.
    public var completionHandler: ((_ sessionCache: SessionCache, _ handler: APIHandlerProtocol) -> Void)!
    
    @available(*, deprecated, message: "use `InstagramLoginWebView` properties instead.")
    /// The login delegate. Deprecated. User `InstagramLoginWebView` closure properties instead.
    public weak var loginDelegate : InstagramLoginWebViewDelegate? {
        didSet {
            didSuccessfullyLogIn = { [weak self] in self?.loginDelegate?.userLoggedSuccessfully() }
            completionHandler = { [weak self] cache, handler in
                self?.loginDelegate?.webViewFinishedToLoadUser(sessionCache: cache, handler: handler)
            }
        }
    }

    // MARK: Init
    public init(frame: CGRect,
                configuration: WKWebViewConfiguration = .init(),
                didReachEndOfLoginFlow: (() -> Void)? = nil,
                didSuccessfullyLogIn: (() -> Void)? = nil,
                completionHandler: ((_ sessionCache: SessionCache, _ handler: APIHandlerProtocol) -> Void)?) {
        // update the process pool.
        let copy = configuration.copy() as! WKWebViewConfiguration
        copy.processPool = WKProcessPool()
        // init login.
        self.didReachEndOfLoginFlow = didReachEndOfLoginFlow
        self.didSuccessfullyLogIn = didSuccessfullyLogIn
        self.completionHandler = completionHandler
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
    }
        
    @available(*, unavailable, message: "use `init(frame:configuration:didReachEndOfLoginFlow:didSuccessfullyLogIn:completionHandler:)` instead.")
    public init(frame: CGRect, configurationBlock: ((WKWebViewConfiguration) -> Void)? = nil) {
        fatalError("init(frame:, configurationBlock:) has been removed")
    }
    @available(*, unavailable, message: "use `init(frame:configuration:didReachEndOfLoginFlow:didSuccessfullyLogIn:completionHandler:)` instead.")
    private override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        fatalError("init(frame:, configuration:) has been removed")
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
        if #available(iOS 11.4, *) {
            self.customUserAgent = "(Linux; Android 5.0; iPhone Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Mobile Safari/537.36"
            //self.customUserAgent = "(Linux; Android 4.4.2; SCH-I545 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.111 Mobile Safari/537.36"
        } else {
            self.customUserAgent = "(Linux; Android 4.4.2; SCH-I545 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.111 Mobile Safari/537.36"
        }
        
        self.load(URLRequest(url: URL(string: urlString)!))
    }
    
    public func isUserLoggedIn(instagramCookies : [HTTPCookie]?) {
        // check for cookies.
        guard let cookies = instagramCookies?.filter({ $0.domain.contains("instagram.com") }) else { return }
        let filtered = cookies.filter { !$0.value.isEmpty && ($0.name == "ds_user_id" || $0.name == "csrftoken" || $0.name == "sessionid") }
        guard filtered.count >= 3 else { return }
        // notify user.
        didReachEndOfLoginFlow?()
        
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
        // notify delegate.
        didSuccessfullyLogIn?()
        // obtain current user.
        try? handler.getCurrentUser { [weak self] in
            guard $0.isSucceeded else { return }
            // obtain current user.
            let currentUser = $0.value?.user
            let shortUserModel = UserShortModel(isVerified: currentUser?.isVerified,
                                                isPrivate: currentUser?.isPrivate,
                                                pk: currentUser?.pk,
                                                profilePicUrl: currentUser?.profilePicUrl,
                                                profilePicId: nil,
                                                username: currentUser?.username,
                                                fullName: currentUser?.fullName,
                                                name: currentUser?.fullName,
                                                address: nil,
                                                shortName: nil,
                                                lng: nil,
                                                lat: nil,
                                                externalSource: nil,
                                                facebookPlacesId: nil,
                                                city: nil,
                                                biography: currentUser?.biography)
            
            HandlerSettings.shared.user!.loggedInUser = shortUserModel
            HandlerSettings.shared.user?.username = shortUserModel.username!
            HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
            HandlerSettings.shared.user?.csrfToken = filtered.first(where: { $0.name == "csrftoken" && !$0.value.isEmpty })!.value
            
            let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!,
                                                 device: HandlerSettings.shared.device!,
                                                 requestMessage: HandlerSettings.shared.request!,
                                                 cookies: cookies.toCookieData(),
                                                 isUserAuthenticated: true)
            // notify delegate.
            self?.completionHandler(sessionCache, handler)
        }
    }

    // MARK: Clean cookies
    private func fetchCookies() {
        configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] in
            self?.isUserLoggedIn(instagramCookies: $0)
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
        // fetch cookies.
        fetchCookies()
    }
}

