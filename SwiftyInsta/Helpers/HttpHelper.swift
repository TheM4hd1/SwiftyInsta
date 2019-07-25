//
//  HttpHelper.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation
import Gzip

class HttpHelper {
    typealias CompletionResult = Result<(Data?, HTTPURLResponse?), Error>
    typealias CompletionHandler = (CompletionResult) -> Void
    weak var handler: APIHandler!

    enum Body {
        case parameters([String: Any])
        case data(Data)
        case gzip([String: Any])
    }

    init(handler: APIHandler) {
        self.handler = handler
    }

    func decodeAsync<D>(_ type: D.Type,
                        method: HTTPMethods,
                        url: URL,
                        body: Body? = nil,
                        headers: [String: String] = [:],
                        checkingValidStatusCode: Bool = true,
                        deliverOnResponseQueue: Bool = true,
                        delay: ClosedRange<Double>? = nil,
                        completionHandler: @escaping (Result<D, Error>) -> Void) where D: Decodable {
        sendAsync(method: method, url: url, body: body, headers: headers, delay: delay) { [weak self] in
            guard let handler = self?.handler else { return completionHandler(.failure(CustomErrors.weakReferenceReleased)) }
            let result = $0.flatMap { data, response -> Result<D, Error> in
                do {
                    guard let data = data, !checkingValidStatusCode || response?.statusCode == 200 else {
                        throw CustomErrors.runTimeError("Invalid response.")
                    }
                    // decode data.
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(D.self, from: data)
                    return .success(decoded)
                } catch { return .failure(error) }
            }
            if deliverOnResponseQueue { handler.settings.queues.response.async { completionHandler(result) }} else { completionHandler(result) }
        }
    }

    func sendAsync(method: HTTPMethods,
                   url: URL,
                   body: Body? = nil,
                   headers: [String: String] = [:],
                   delay: ClosedRange<Double>? = nil,
                   completionHandler: @escaping CompletionHandler) {
        // prepare for requesting `url`.
        let delay = (delay ?? handler.settings.delay).flatMap { Double.random(in: $0) } ?? 0
        handler.settings.queues.request.asyncAfter(deadline: .now()+delay) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(CustomErrors.runTimeError("`weak` reference was released.")))
            }
            // obtain the request.
            var request = me.getDefaultRequest(for: url, method: body == nil ? method : .post)
            self?.addHeaders(to: &request, header: headers)
            switch body {
            case .parameters(let parameters)?: me.addBody(to: &request, body: parameters)
            case .data(let data)?: request.httpBody = data
            case .gzip(let parameters)?:
                me.addHeaders(to: &request, header: ["Content-Encoding": "gzip"])
                me.addBody(to: &request, body: parameters)
                request.httpBody = request.httpBody.flatMap { try? $0.gzipped() }
            default: break
            }
            // start task.
            handler.settings.session.dataTask(with: request) { data, response, error in
                handler.settings.queues.working.async {
                    switch error {
                    case let error?: completionHandler(.failure(error))
                    default: completionHandler(.success((data, response as? HTTPURLResponse)))
                    }
                }
            }.resume()
        }
    }

    func sendSync(method: HTTPMethods,
                  url: URL,
                  body: Body? = nil,
                  headers: [String: String] = [:]) -> CompletionResult {
        // obtain the request.
        var request = getDefaultRequest(for: url, method: body == nil ? method : .post)
        addHeaders(to: &request, header: headers)
        switch body {
        case .parameters(let parameters)?: addBody(to: &request, body: parameters)
        case .data(let data)?: request.httpBody = data
        default: break
        }
        // wait for task to complete.
        let semaphore = DispatchSemaphore(value: 0)
        var result: CompletionResult!
        handler.settings.session.dataTask(with: request) { data, response, error in
            switch error {
            case let error?: result = .failure(error)
            default: result = .success((data, response as? HTTPURLResponse))
            }
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return result
    }

    func getDefaultRequest(for url: URL, method: HTTPMethods) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = method.rawValue
        request.addValue(Headers.acceptLanguageValue, forHTTPHeaderField: Headers.acceptLanguageKey)
        request.addValue(Headers.igCapabilitiesValue, forHTTPHeaderField: Headers.igCapabilitiesKey)
        request.addValue(Headers.igConnectionTypeValue, forHTTPHeaderField: Headers.igConnectionTypeKey)
        request.addValue(Headers.contentTypeApplicationFormValue, forHTTPHeaderField: Headers.contentTypeKey)
        request.addValue(Headers.userAgentValue, forHTTPHeaderField: Headers.userAgentKey)
        // remove old values and updates with new one.
        handler.settings.headers.forEach { key, value in request.setValue(value, forHTTPHeaderField: key) }
        return request
    }

    fileprivate func addHeaders(to request: inout URLRequest, header: [String: String]) {
        header.forEach { request.allHTTPHeaderFields?.updateValue($0.value, forKey: $0.key) }
    }

    fileprivate func addBody(to request: inout URLRequest, body: [String: Any]) {
        if !body.isEmpty {
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

        HTTPCookieStorage.shared.setCookies(cookies, for: URLs.getInstagramCookieUrl(), mainDocumentURL: nil)
    }
}
