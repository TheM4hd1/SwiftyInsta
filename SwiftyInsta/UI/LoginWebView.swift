//
//  LoginWebView.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/19/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

#if canImport(WebKit)
import WebKit

// MARK: Views
public class LoginWebView: WKWebView, WKNavigationDelegate {
    /// Called when reaching the end of the login flow.
    /// You should probably hide the `InstagramLoginWebView` and notify the user with an activity indicator.
    public var didReachEndOfLoginFlow: (() -> Void)?
    /// Called once the flow is completed.
    var completionHandler: ((Result<[HTTPCookie], Error>) -> Void)!

    private var cookieTimer: Timer?

    // MARK: Init
    public init(frame: CGRect, didReachEndOfLoginFlow: (() -> Void)? = nil) {
        // delete all cookies.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // update the process pool.
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        // init login.
        self.didReachEndOfLoginFlow = didReachEndOfLoginFlow
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
        setCookieTimer()
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

            #if os(iOS) && !targetEnvironment(macCatalyst)
            let deviceVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            me.customUserAgent = ["Mozilla/5.0 (iPhone; CPU iPhone OS \(deviceVersion) like Mac OS X)",
                                  "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                                  "Mobile/15E148"].joined(separator: " ")
            #else
            me.customUserAgent = ["Mozilla/5.0 (iPhone; CPU iPhone OS 13_4_1 like Mac OS X)",
                                  "AppleWebKit/605.1.15 (KHTML, like Gecko)",
                                  "Mobile/15E148"].joined(separator: " ")
            #endif

            // load request.
            me.load(URLRequest(url: url))
        }
    }

    // MARK: Clean cookies

    private func setCookieTimer() {
        cookieTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tryFetchingCookies()
        }
    }

    private func tryFetchingCookies() {
        configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] in
            let data = $0.filter({ $0.domain.contains(".instagram.com") })
            let filtered = data.filter {
                ($0.name == "ds_user_id" || $0.name == "csrftoken" || $0.name == "sessionid")
                    && !$0.value.isEmpty
            }
            guard filtered.count >= 3 else { return }
            // notify completion.
            self?.didReachEndOfLoginFlow?()
            // no need to check anymore.
            self?.navigationDelegate = nil
            // notify user.
            self?.completionHandler?(.success($0))
            // deinit timer
            self?.cookieTimer?.invalidate()
            self?.cookieTimer = nil
        }
    }

    private func deleteAllCookies(completionHandler: @escaping () -> Void = { }) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                modifiedSince: .distantPast,
                                                completionHandler: completionHandler)
    }

}
#endif
