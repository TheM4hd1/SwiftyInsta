//
//  WKCookieWebViewPreloader.swift
//  WKCookieWebView
//
//  Created by Taeun Kim on 11/02/2019.
//
import Foundation
import UIKit
import WebKit

final class WKCookieWebViewPreloader: NSObject, WKNavigationDelegate {
    
    private var handler: (WKWebView) -> Void
    
    init(webView: WKCookieWebView, handler: @escaping (WKWebView) -> Void) {
        self.handler = handler
        super.init()
        webView.wkNavigationDelegate = self
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handler(webView)
    }
    
}

public extension WKCookieWebView {
    
    enum AssociatedKeys {
        static var preloader: String = "preloader"
    }
    
    private var preloader: WKCookieWebViewPreloader? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.preloader) as? WKCookieWebViewPreloader }
        set { objc_setAssociatedObject(self, &AssociatedKeys.preloader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @objc
    class func preloadWithDomainForCookieSync(urlString: String,
                                              completion: (() -> Void)? = nil) {
        guard let url = URL(string: urlString),
            let window = UIApplication.shared.keyWindow else {
                completion?()
                return
        }
        
        let webView = WKCookieWebView(frame: CGRect(origin: CGPoint(x: -1, y: -1), size: CGSize(width: 1, height: 1)),
                                      configurationBlock: nil)
        webView.alpha = 0.1
        webView.preloader = WKCookieWebViewPreloader(webView: webView, handler: { view in
            completion?()
            view.removeFromSuperview()
        })
        webView.load(URLRequest(url: url))
        window.addSubview(webView)
    }
    
}
