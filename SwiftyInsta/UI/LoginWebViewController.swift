//
//  LoginWebViewController.swift
//  SwiftyInsta.iOS
//
//  Created by Stefano Bertagno on 10/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

#if os(iOS)
import UIKit
import WebKit

@available(iOS 11, OSX 10.11, macCatalyst 13, *)
/// A pre-built `UIViewController` displaying a `LoginWebView`.
public class LoginWebViewController: UIViewController {
    /// The handler.
    public let handler = APIHandler()
    /// The completion handler. **Required**.
    public var completionHandler: (LoginWebViewController, Result<(Authentication.Response, APIHandler), Error>) -> Void
    /// The activity indicator.
    public var indicator: UIActivityIndicatorView! {
        didSet {
            oldValue?.removeFromSuperview()
            guard let indicator = indicator else { return }
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicator)
            indicator.startAnimating()
            // center.
            NSLayoutConstraint.activate(
                [indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
            )
        }
    }
    /// The web view.
    public var webView: LoginWebView! {
        didSet {
            oldValue?.removeFromSuperview()
            guard let webView = webView else { return }
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            // stop animating.
            indicator?.stopAnimating()
            // center.
            NSLayoutConstraint.activate(
                [webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                 webView.rightAnchor.constraint(equalTo: view.rightAnchor),
                 webView.topAnchor.constraint(equalTo: view.topAnchor),
                 webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
            )
        }
    }

    // MARK: Init
    @available(*, unavailable, message: "using a custom `userAgent` is no longer supported")
    public init(userAgent: String?,
                completionHandler: @escaping (LoginWebViewController, Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        fatalError("Unavailable method.")
    }

    public init(completionHandler: @escaping (LoginWebViewController, Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        // setup views.
        view.backgroundColor = .white
        indicator = .init(style: .gray)
        // init the web view.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                                modifiedSince: .distantPast) { [weak self] in
                                                    self?.webView = LoginWebView(frame: self?.view.bounds ?? .zero) {
                                                        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                                                                       animations: { self?.webView?.alpha = 0 },
                                                                       completion: { self?.webView?.isHidden = $0 })
                                                        // start animating indicator.
                                                        self?.indicator.startAnimating()
                                                    }
                                                    // authenticate.
                                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                                        self?.authenticate()
                                                    }
        }
        // navigation helpers.
        title = "Login"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(dismissWithAnimation))
    }

    // MARK: Internal methods
    func authenticate() {
        guard let webView = webView else { return }
        handler.authenticate(with: .webView(webView)) { [weak self] in
            guard let self = self else { return }
            self.completionHandler(self, $0)
        }
    }

    @objc func dismissWithAnimation() {
        dismiss(animated: true, completion: nil)
    }
}
#endif
