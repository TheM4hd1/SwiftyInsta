//
//  WKCookieWebView.swift
//  Example
//
//  Created by kofktu on 2017. 6. 24..
//  Copyright © 2017년 Kofktu. All rights reserved.
//
import UIKit
import Foundation
import WebKit

fileprivate class WKCookieProcessPool: WKProcessPool {
    static let pool = WKCookieProcessPool()
}

open class WKCookieWebView: WKWebView {
    
    // Must use this instead of navigationDelegate
    @objc public weak var wkNavigationDelegate: WKNavigationDelegate?
    
    // If necessary, use clousre instead of delegate
    @objc public var onDecidePolicyForNavigationAction: ((WKWebView, WKNavigationAction, @escaping (WKNavigationActionPolicy) -> Swift.Void) -> Void)?
    @objc public var onDecidePolicyForNavigationResponse: ((WKWebView, WKNavigationResponse, @escaping (WKNavigationResponsePolicy) -> Swift.Void) -> Void)?
    @objc public var onDidReceiveChallenge: ((WKWebView, URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) -> Void)?
    
    // The closure where cookie information is called at update time
    @objc public var onUpdateCookieStorage: ((WKCookieWebView) -> Void)?
    
    private var updatedCookies = [String]()
    
    @objc
    public init(frame: CGRect, configurationBlock: ((WKWebViewConfiguration) -> Void)? = nil) {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKCookieProcessPool.pool
        configurationBlock?(configuration)
        super.init(frame: frame, configuration: configuration)
        configuration.userContentController = userContentWithCookies()
        navigationDelegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, init(frame:configurationBlock:)")
    }
    
    // MARK: - Private
    private func userContentWithCookies() -> WKUserContentController {
        let userContentController = configuration.userContentController
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            let now = Date()
            
            for cookie in cookies {
                if let expiresDate = cookie.expiresDate, now.compare(expiresDate) == .orderedDescending {
                    // Expire
                    delete(cookie: cookie)
                    continue
                }
                
                let value = "document.cookie='\(cookie.name)=\(cookie.value);domain=\(cookie.domain);path=\(cookie.path);';"
                userContentController.addUserScript(WKUserScript(source: value,
                                                                 injectionTime: .atDocumentStart,
                                                                 forMainFrameOnly: false))
                updatedCookies.append(cookie.name)
                
                if #available(iOS 11.0, *) {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie, completionHandler: nil)
                }
            }
        }
        
        return userContentController
        
    }
    
    private func update(webView: WKWebView) {
        // WKWebView -> HTTPCookieStorage
        webView.evaluateJavaScript("document.cookie;") { [weak self] (result, error) in
            guard let host = self?.url?.host,
                let documentCookie = result as? String else {
                    return
            }
            
            self?.fetchCookies(fileter: host, completion: { [weak self] (cookies) in
                self?.update(with: cookies, documentCookie: documentCookie, host: host)
            })
        }
    }
    
    private func update(with cachedCookies: [HTTPCookie]?, documentCookie: String, host: String) {
        let cookieValues = documentCookie.components(separatedBy: "; ")
        
        for value in cookieValues {
            var comps = value.components(separatedBy: "=")
            if comps.count < 2 { continue }
            
            let cookieName = comps.removeFirst()
            let cookieValue = comps.joined(separator: "=")
            let localCookie = cachedCookies?.filter { $0.name == cookieName }.first
            
            if let localCookie = localCookie {
                if !cookieValue.isEmpty && localCookie.value != cookieValue {
                    // set/update cookie
                    var properties: [HTTPCookiePropertyKey: Any] = localCookie.properties ?? [
                        .name: localCookie.name,
                        .domain: localCookie.domain,
                        .path: localCookie.path
                    ]
                    
                    properties[.value] = cookieValue
                    
                    self.delete(cookie: localCookie)
                    
                    if let cookie = HTTPCookie(properties: properties) {
                        self.set(cookie: cookie)
                        self.onUpdateCookieStorage?(self)
                    }
                }
            } else {
                if !cookieName.isEmpty && !cookieValue.isEmpty {
                    let properties: [HTTPCookiePropertyKey: Any] = [
                        .name: cookieName,
                        .value: cookieValue,
                        .domain: host,
                        .path: "/"
                    ]
                    
                    if let cookie = HTTPCookie(properties: properties) {
                        // set cookie
                        self.set(cookie: cookie)
                        self.onUpdateCookieStorage?(self)
                    }
                }
            }
        }
    }
    
    private func update(cookies: [HTTPCookie]?) {
        cookies?.forEach {
            set(cookie: $0)
            
            if !updatedCookies.contains($0.name) {
                updatedCookies.append($0.name)
            }
        }
        
        onUpdateCookieStorage?(self)
    }
    
}

extension WKCookieWebView {
    
    typealias HTTPCookieHandler = ([HTTPCookie]?) -> Void
    
    func fetchCookies(completion: @escaping HTTPCookieHandler) {
        if #available(iOS 11.0, *) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies(completion)
        } else {
            completion(HTTPCookieStorage.shared.cookies)
        }
    }
    
    func fetchCookies(fileter host: String, completion: @escaping HTTPCookieHandler) {
        fetchCookies { (cookies) in
            completion(cookies?.filter { host.range(of: $0.domain) != nil })
        }
    }
    
    func set(cookie: HTTPCookie) {
        HTTPCookieStorage.shared.setCookie(cookie)
        
        if #available(iOS 11.0, *) {
            WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie, completionHandler: nil)
        }
    }
    
    func delete(cookie: HTTPCookie) {
        HTTPCookieStorage.shared.deleteCookie(cookie)
        
        if #available(iOS 11.0, *) {
            WKWebsiteDataStore.default().httpCookieStore.delete(cookie, completionHandler: nil)
        }
    }
    
}


extension WKCookieWebView: WKNavigationDelegate {
    
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let handler = onDecidePolicyForNavigationAction {
            handler(webView, navigationAction, decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        defer {
            if let handler = onDecidePolicyForNavigationResponse {
                handler(webView, navigationResponse, decisionHandler)
            } else {
                decisionHandler(.allow)
            }
        }
        
        guard let response = navigationResponse.response as? HTTPURLResponse,
            let allHeaderFields = response.allHeaderFields as? [String: String],
            let url = response.url else {
                return
        }
        
        update(cookies: HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url))
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        wkNavigationDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        wkNavigationDelegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        wkNavigationDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        update(webView: webView)
        wkNavigationDelegate?.webView?(webView, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        wkNavigationDelegate?.webView?(webView, didFinish: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        wkNavigationDelegate?.webView?(webView, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if let handler = onDidReceiveChallenge {
            handler(webView, challenge, completionHandler)
        } else {
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    credential = URLCredential(trust: serverTrust)
                    disposition = .useCredential
                }
            } else {
                disposition = .cancelAuthenticationChallenge
            }
            
            completionHandler(disposition, credential)
        }
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        wkNavigationDelegate?.webViewWebContentProcessDidTerminate?(webView)
    }
    
}
