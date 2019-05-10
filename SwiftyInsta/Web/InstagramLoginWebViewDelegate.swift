//
//  InstagramLoginWebView.swift
//  SwiftyInsta
//
//  Created by Sehmus GOKCE on 15.04.2019. (freeman4706@github)
//  Copyright © 2019 Mahdi. All rights reserved.
//

import UIKit
import WebKit


public protocol InstagramLoginWebViewDelegate {
    func userLoggedSuccessfully()
    func webViewFinishedToLoadUser(sessionCache : SessionCache, handler: APIHandlerProtocol)
}


public class InstagramLoginWebView: WKCookieWebView {
    
    public var loginDelegate : InstagramLoginWebViewDelegate?
    
    public  override init(frame: CGRect, configurationBlock: ((WKWebViewConfiguration) -> Void)? = nil) {
        super.init(frame: frame, configurationBlock: configurationBlock)
        self.wkNavigationDelegate = self
        self.setCallbacks()
    }
    
    private func setCallbacks() {
        onDecidePolicyForNavigationResponse = { (webView, response, decide) in
            decide(.allow)
        }
        
        onUpdateCookieStorage = { webView in
            self.fetchCookies(completion: { (cookies) in
                var isLogged = false
                for cookie in cookies! {
                    if cookie.name == "ds_user_id" {
                        isLogged = true
                    }
                }
                if isLogged {
                    for cookie in cookies! {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                    
                }
            })
        }
    }
    
    public func loadInstagramLogin(isNeedPreloadForCookieSync : Bool) {
        self.deleteAllCookies()
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
        
        if isNeedPreloadForCookieSync {
            WKCookieWebView.preloadWithDomainForCookieSync(urlString: urlString) { [weak self] in
                self!.load(URLRequest(url: URL(string: urlString)!))
            }
        } else {
            self.load(URLRequest(url: URL(string: urlString)!))
        }
    }
    
    public func isUserLoggedIn(instagramCookies : [HTTPCookie]) {
        var isLogged = false
        var csrfToken = ""
        for cookie in instagramCookies {
            if cookie.name == "ds_user_id"
            {
                isLogged = true
            }
            if cookie.name == "csrftoken"
            {
                csrfToken = cookie.value
            }
        }
        
        if isLogged {
            let _urlSession = URLSession(configuration: .default)
            let user = SessionStorage.create(username: "username", password: "password")
            let instagramHandler = try! APIBuilder()
                .createBuilder()
                .setHttpHandler(urlSession: _urlSession)
                .setRequestDelay(delay: .default)
                .setUser(user: user)
                .build()
            
            let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)
            try? instagramHandler.login(cache: sessionCache, completion: { (result) in
                
            })
            
            if self.loginDelegate != nil {
                self.loginDelegate?.userLoggedSuccessfully()
            }
            
            try? instagramHandler.getCurrentUser { (currentUserModel) in
                if currentUserModel.isSucceeded {
                    let currentUser = currentUserModel.value?.user
                    let shortUserModel = UserShortModel(isVerified: currentUser?.isVerified, isPrivate: currentUser?.isPrivate, pk: currentUser?.pk, profilePicUrl: currentUser?.profilePicUrl, profilePicId: nil, username: currentUser?.username, fullName: currentUser?.fullName, name: currentUser?.fullName, address: nil, shortName: nil, lng: nil, lat: nil, externalSource: nil, facebookPlacesId: nil, city: nil, biography: currentUser?.biography)
                    
                    HandlerSettings.shared.user!.loggedInUser = shortUserModel
                    HandlerSettings.shared.user?.username = shortUserModel.username!
                    HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
                    HandlerSettings.shared.user?.csrfToken = csrfToken
                    
                    let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)
                    
                    if self.loginDelegate != nil {
                        self.loginDelegate?.webViewFinishedToLoadUser(sessionCache: sessionCache, handler: instagramHandler)
                    }
                }
            }
        }
        
    }
    
    public func deleteAllCookies() {
        
        self.cleanEveryThing()
        
        fetchCookies { (cookies) in
            for cookie in cookies! {
                self.delete(cookie: cookie)
            }
        }
    }
    
    func cleanEveryThing() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    public override func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public override func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    public override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    public override func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    public override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("URL of Finished::::" + webView.url!.absoluteString)
        
        self.fetchCookies(completion: { (cookies) in
            let instagramCookies =  cookies?.getInstagramCookies()
            
            //            for cookie in instagramCookies! {
            //                print(cookie)
            //            }
            
            self.isUserLoggedIn(instagramCookies: instagramCookies!)
        })
    }
    
    public override func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    @available(iOS 9.0, *)
    public override func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
}
