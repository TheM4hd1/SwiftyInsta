//
//  HTTPHelper.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation
// import Gzip

/// An _abstract_ `class` providing reference for all `*Handler`s.
class HTTPHelper {
    /// The completion response.
    typealias CompletionResult = Result<(Data?, HTTPURLResponse?), Error>
    /// The completion handller.
    typealias CompletionHandler = (CompletionResult) -> Void

    /// The `HTTP` method.
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    /// A body for the `URLRequest`.
    enum Body {
        case parameters([String: Any])
        case data(Data)
        // case gzip([String: Any])
    }

    /// The referenced handler.
    weak var handler: APIHandler!

    /// Init with `handler`.
    init(handler: APIHandler) {
        self.handler = handler
    }

    /// Parse.
    func parse<R>(_ type: R.Type,
                  method: Method,
                  url: Result<URL, Error>,
                  body: Body? = nil,
                  headers: [String: String] = [:],
                  checkingValidStatusCode: Bool = true,
                  deliverOnResponseQueue: Bool = true,
                  delay: ClosedRange<Double>? = nil,
                  processingHandler: @escaping (DynamicResponse) -> R,
                  completionHandler: @escaping (Result<R, Error>) -> Void) {
        fetch(method: method, url: url, body: body, headers: headers, delay: delay) { [weak self] in
            guard let handler = self?.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            let result = $0.flatMap { data, response -> Result<R, Error> in
                do {
                    guard let data = data, !checkingValidStatusCode || response?.statusCode == 200 else {
                        throw GenericError.custom("Invalid response.")
                    }
                    // decode data.
                    let decoded = try DynamicResponse(data: data)
                    return .success(processingHandler(decoded))
                } catch { return .failure(error) }
            }
            if deliverOnResponseQueue { handler.settings.queues.response.async { completionHandler(result) }} else { completionHandler(result) }
        }
    }
    /// Parse endpoint response.
    func parse<R>(_ type: R.Type,
                  method: Method,
                  url: Result<URL, Error>,
                  body: Body? = nil,
                  headers: [String: String] = [:],
                  checkingValidStatusCode: Bool = true,
                  deliverOnResponseQueue: Bool = true,
                  delay: ClosedRange<Double>? = nil,
                  completionHandler: @escaping (Result<R, Error>) -> Void) where R: ParsedResponse {
        parse(type,
              method: method,
              url: url,
              body: body,
              headers: headers,
              delay: delay,
              processingHandler: { R(rawResponse: $0) },
              completionHandler: completionHandler)
    }
    /// Parse accessory.
    func parse<R>(_ type: R.Type,
                  method: Method,
                  url: URL,
                  body: Body? = nil,
                  headers: [String: String] = [:],
                  checkingValidStatusCode: Bool = true,
                  deliverOnResponseQueue: Bool = true,
                  delay: ClosedRange<Double>? = nil,
                  completionHandler: @escaping (Result<R, Error>) -> Void) where R: ParsedResponse {
        parse(type,
              method: method,
              url: Result { url },
              body: body,
              headers: headers,
              checkingValidStatusCode: checkingValidStatusCode,
              deliverOnResponseQueue: deliverOnResponseQueue,
              delay: delay,
              completionHandler: completionHandler)
    }

    /// Decoding accessory.
    func decode<D>(_ type: D.Type,
                   method: Method,
                   url: URL,
                   body: Body? = nil,
                   headers: [String: String] = [:],
                   checkingValidStatusCode: Bool = true,
                   deliverOnResponseQueue: Bool = true,
                   delay: ClosedRange<Double>? = nil,
                   completionHandler: @escaping (Result<D, Error>) -> Void) where D: Decodable {
        decode(type,
               method: method,
               url: Result { url },
               body: body,
               headers: headers,
               checkingValidStatusCode: checkingValidStatusCode,
               deliverOnResponseQueue: deliverOnResponseQueue,
               delay: delay,
               completionHandler: completionHandler)
    }
    /// Decode endpoint response.
    func decode<D>(_ type: D.Type,
                   method: Method,
                   url: Result<URL, Error>,
                   body: Body? = nil,
                   headers: [String: String] = [:],
                   checkingValidStatusCode: Bool = true,
                   deliverOnResponseQueue: Bool = true,
                   delay: ClosedRange<Double>? = nil,
                   completionHandler: @escaping (Result<D, Error>) -> Void) where D: Decodable {
        fetch(method: method, url: url, body: body, headers: headers, delay: delay) { [weak self] in
            guard let handler = self?.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            let result = $0.flatMap { data, response -> Result<D, Error> in
                do {
                    guard let data = data, !checkingValidStatusCode || response?.statusCode == 200 else {
                        throw GenericError.custom("Invalid response.")
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

    /// Accessory fetch async resource.
    func fetch(method: Method,
               url: URL,
               body: Body? = nil,
               headers: [String: String] = [:],
               delay: ClosedRange<Double>? = nil,
               completionHandler: @escaping CompletionHandler) {
        fetch(method: method, url: Result { url }, body: body, headers: headers, delay: delay, completionHandler: completionHandler)
    }
    /// Fetch async resource.
    func fetch(method: Method,
               url: Result<URL, Error>,
               body: Body? = nil,
               headers: [String: String] = [:],
               delay: ClosedRange<Double>? = nil,
               completionHandler: @escaping CompletionHandler) {
        guard let content = try? url.get() else { return completionHandler(.failure(GenericError.invalidUrl)) }
        // prepare for requesting `url`.
        let delay = (delay ?? handler.settings.delay).flatMap { Double.random(in: $0) } ?? 0
        handler.settings.queues.request.asyncAfter(deadline: .now()+delay) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.custom("`weak` reference was released.")))
            }
            // obtain the request.
            var request = me.getDefaultRequest(for: content, method: body == nil ? method : .post)
            self?.addHeaders(to: &request, header: headers)
            switch body {
            case .parameters(let parameters)?: me.addBody(to: &request, body: parameters)
            case .data(let data)?: request.httpBody = data
            /*case .gzip(let parameters)?:
                me.addHeaders(to: &request, header: ["Content-Encoding": "gzip"])
                me.addBody(to: &request, body: parameters)
                request.httpBody = request.httpBody.flatMap { try? $0.gzipped() }*/
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

    func getDefaultRequest(for url: URL, method: Method) -> URLRequest {
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

    func setCookies(_ cookiesData: [Data]) throws {
        var cookies = [HTTPCookie]()
        for data in cookiesData {
            if let cookieFromData = HTTPCookie.load(from: data) {
                cookies.append(cookieFromData)
            }
        }
        HTTPCookieStorage.shared.setCookies(cookies,
                                            for: try URLs.getInstagramCookieUrl(),
                                            mainDocumentURL: nil)
    }
}
