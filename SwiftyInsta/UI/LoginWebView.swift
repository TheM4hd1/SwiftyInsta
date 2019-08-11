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
    /// Whether javascript injection should be used to make web pages less crowded.
    var shouldImproveReadability: Bool
    /// Called when reaching the end of the login flow.
    /// You should probably hide the `InstagramLoginWebView` and notify the user with an activity indicator.
    public var didReachEndOfLoginFlow: (() -> Void)?
    /// Called once the flow is completed.
    var completionHandler: ((Result<[HTTPCookie], Error>) -> Void)!

    // MARK: Init
    public init(frame: CGRect,
                improvingReadability shouldImproveReadability: Bool = true,
                didReachEndOfLoginFlow: (() -> Void)? = nil) {
        // delete all cookies.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // update the process pool.
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        // improve readability.
        if shouldImproveReadability {
            let user = WKUserContentController()
            let hideHeader = """
                var el = document.getElementsByClassName('lOPC8 DPEif'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                """
            let hideAppStoreBanner = """
                var el = document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msl'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                """
            let hideFooter = """
                var el = document.getElementsByClassName(' tHaIX Igw0E rBNOH YBx95 ybXk5 _4EzTm O1flK _7JkPY PdTAI ZUqME'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                """
            user.addUserScript(WKUserScript(source: hideHeader,
                                            injectionTime: .atDocumentEnd,
                                            forMainFrameOnly: false))
            user.addUserScript(WKUserScript(source: hideAppStoreBanner,
                                            injectionTime: .atDocumentEnd,
                                            forMainFrameOnly: false))
            user.addUserScript(WKUserScript(source: hideFooter,
                                            injectionTime: .atDocumentEnd,
                                            forMainFrameOnly: false))
            configuration.userContentController = user
        }
        // init login.
        self.didReachEndOfLoginFlow = didReachEndOfLoginFlow
        self.shouldImproveReadability = shouldImproveReadability
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
    }

    @available(*, unavailable, message: "use `init(frame:configuration:didReachEndOfLoginFlow:didSuccessfullyLogIn:completionHandler:)` instead.")
    private override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        fatalError("init(frame:, configuration:) has been removed")
    }
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Log in
    func authenticate(completionHandler: @escaping (Result<[HTTPCookie], Error>) -> Void) {
        // update completion handler.
        self.completionHandler = completionHandler
        // wipe all cookies and wait to load.
        deleteAllCookies { [weak self] in
            guard let me = self else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            guard let url = URL(string: "https://www.instagram.com/accounts/login/") else {
                return completionHandler(.failure(GenericError.custom("Invalid URL.")))
            }
            // in some iOS versions, use-agent needs to be different.
            // this use-agent works on iOS 11.4 and iOS 12.0+
            // but it won't work on lower versions.
            me.customUserAgent = ["(Linux; Android 5.0; iPhone Build/LRX21T)",
                                  "AppleWebKit/537.36 (KHTML, like Gecko)",
                                  "Chrome/70.0.3538.102 Mobile Safari/537.36"].joined(separator: " ")
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

    private func deleteAllCookies(completionHandler: @escaping () -> Void = { }) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                modifiedSince: .distantPast,
                                                completionHandler: completionHandler)
    }

    // MARK: Navigation delegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch webView.url?.absoluteString {
        case "https://www.instagram.com/"?:
            // notify user.
            didReachEndOfLoginFlow?()
            // fetch cookies.
            fetchCookies()
            // no need to check anymore.
            navigationDelegate = nil
        case "https://www.instagram.com/accounts/login/"?:
            guard shouldImproveReadability else { break }
            // do nothing, just wait.
            webView.evaluateJavaScript(
                """
                var el = document.getElementsByClassName('lOPC8 DPEif'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                var el = document.getElementsByClassName('MFkQJ ABLKx VhasA _1-msl'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                var el = document.getElementsByClassName(' tHaIX Igw0E rBNOH YBx95 ybXk5 _4EzTm O1flK _7JkPY PdTAI ZUqME'); \
                if (el.length > 0) el[0].parentNode.removeChild(el[0]);
                """,
                completionHandler: nil
            )
        default:
            // check for cookies.
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] in
                let filtered = $0.filter { ["ds_user_id", "csrftoken", "sessionid"].contains($0.name) }
                    .filter { !$0.value.isEmpty }
                guard filtered.count >= 3 else { return }
                // notify user.
                self?.didReachEndOfLoginFlow?()
                // fetch cookies.
                self?.completionHandler?(.success($0))
                // no need to check anymore.
                self?.navigationDelegate = nil
            }
        }
    }
}
#endif
