//
//  HttpHelper.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

class HttpHelper {
    
    typealias completionHandler = (Data?, HTTPURLResponse?, Error?) -> Void
    private var session: URLSession
    
    init(urlSession: URLSession) {
        session = urlSession
    }
    
    /// Only ```data: Data?``` or ```body: [String: Any]``` can use as ```httpBody```
    func sendAsync(method: HTTPMethods, url: URL, body: [String: Any], header: [String: String], data: Data? = nil, completion: @escaping completionHandler) {
        HandlerSettings.shared.queue!.asyncAfter(deadline: .now() + HandlerSettings.shared.delay!.random()) {
            var request = self.getDefaultRequest(for: url, method: method)
            self.addHeaders(to: &request, header: header)
            //addBody(to: &request, body: body)
            
            if let data = data {
                request.httpBody = data
            } else {
                self.addBody(to: &request, body: body)
            }
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
                completion(data, response as? HTTPURLResponse, error)
            }
            
            task.resume()
        }
    }
    
    func sendSync(method: HTTPMethods, url: URL, body: [String: Any], header: [String: String]) -> (Data?, HTTPURLResponse?, Error?) {
        var request = getDefaultRequest(for: url, method: method)
        var result: (Data?, HTTPURLResponse?, Error?)
        addHeaders(to: &request, header: header)
        addBody(to: &request, body: body)
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request) { (data, response, error) in
            result = (data, response as? HTTPURLResponse, error)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result
    }
    
    func getDefaultRequest(for url: URL, method: HTTPMethods) -> URLRequest {//, device: AndroidDeviceModel) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = method.rawValue
        request.addValue(Headers.HeaderAcceptLanguageValue, forHTTPHeaderField: Headers.HeaderAcceptLanguageKey)
        request.addValue(Headers.HeaderIGCapablitiesValue, forHTTPHeaderField: Headers.HeaderIGCapablitiesKey)
        request.addValue(Headers.HeaderIGConnectionTypeValue, forHTTPHeaderField: Headers.HeaderIGConnectionTypeKey)
        request.addValue(Headers.HeaderContentTypeApplicationFormValue, forHTTPHeaderField: Headers.HeaderContentTypeKey)
        request.addValue(Headers.HeaderUserAgentValue, forHTTPHeaderField: Headers.HeaderUserAgentKey)
        
        // remove old values and updates with new one.
        if HttpSettings.shared.getHeaders().count > 0 {
            let headers = HttpSettings.shared.getHeaders()
            headers.forEach { (key, value) in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    fileprivate func addHeaders(to request: inout URLRequest, header: [String: String]) {
        if header.count > 0 {
            header.forEach { (key, value) in
                request.allHTTPHeaderFields?.updateValue(value, forKey: key)
                //request.addValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    fileprivate func addBody(to request: inout URLRequest, body: [String: Any]) {
        if body.count > 0 {
            var queries: [String] = []
            body.forEach { (parameterName, parameterValue) in
                let query = "\(parameterName)=\(parameterValue)"
                queries.append(query)
            }
            
            let data = queries.joined(separator: "&")
            request.httpBody = data.data(using: String.Encoding.utf8)
        }
    }
    
    func setCookies(_ cookiesData: [Data]) {
        var cookies = [HTTPCookie]()
        for data in cookiesData {
            if let cookieFromData = HTTPCookie.loadCookie(using: data) {
                cookies.append(cookieFromData)
            }
        }
        
        try? HTTPCookieStorage.shared.setCookies(cookies, for: URLs.getInstagramCookieUrl(), mainDocumentURL: nil)
    }
}
