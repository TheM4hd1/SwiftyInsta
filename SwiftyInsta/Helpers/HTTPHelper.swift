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
    /// A list of options.
    struct Options: OptionSet {
        let rawValue: Int
        
        /// Validate response.
        static let validateResponse = Options(rawValue: 1 << 0)
        /// Deliver on response queue.
        static let deliverOnResponseQueue = Options(rawValue: 1 << 1)
        
        /// Default.
        static let `default`: Options = [.validateResponse, .deliverOnResponseQueue]
    }

    /// The referenced handler.
    weak var handler: APIHandler!

    /// Init with `handler`.
    init(handler: APIHandler) {
        self.handler = handler
    }

    // MARK: Parse
    /// Parse a specific `Response`.
    func request<Response>(_ response: Response.Type,
                           method: Method,
                           endpoint: Endpoint,
                           body: Body? = nil,
                           headers: [String: String]? = nil,
                           options: Options = .default,
                           delay: ClosedRange<Double>? = nil,
                           process: @escaping (DynamicResponse) -> Response,
                           completion: @escaping(Result<Response, Error>) -> Void) {
        // fetch and parse response.
        request(response,
                method: method,
                endpoint: endpoint,
                body: body,
                headers: headers,
                options: options,
                delay: delay,
                process: { Optional.some(process($0)) },
                completion: completion)
    }
    /// Parse a specific `Decodable`.
    func request<Response>(_ response: Response.Type,
                           method: Method,
                           endpoint: Endpoint,
                           body: Body? = nil,
                           headers: [String: String]? = nil,
                           options: Options = .default,
                           delay: ClosedRange<Double>? = nil,
                           completion: @escaping(Result<Response, Error>) -> Void) where Response: Decodable {
        // fetch and parse response.
        request(response,
                method: method,
                endpoint: endpoint,
                body: body,
                headers: headers,
                options: options,
                delay: delay,
                process: { response -> Response? in
                    guard let data = try? response.data() else { return nil }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try? decoder.decode(Response.self, from: data)
        },
                completion: completion)
    }
    /// Parse a specific `ParsedResponse`.
    func request<Response>(_ response: Response.Type,
                           method: Method,
                           endpoint: Endpoint,
                           body: Body? = nil,
                           headers: [String: String]? = nil,
                           options: Options = .default,
                           delay: ClosedRange<Double>? = nil,
                           completion: @escaping(Result<Response, Error>) -> Void) where Response: ParsedResponse {
        // fetch and parse response.
        request(response,
                method: method,
                endpoint: endpoint,
                body: body,
                headers: headers,
                options: options,
                delay: delay,
                process: Response.init,
                completion: completion)
    }
    /// Parse a specific optional `Response`.
    func request<Response>(_ response: Response.Type,
                           method: Method,
                           endpoint: Endpoint,
                           body: Body? = nil,
                           headers: [String: String]? = nil,
                           options: Options = .default,
                           delay: ClosedRange<Double>? = nil,
                           process: @escaping (DynamicResponse) -> Response?,
                           completion: @escaping(Result<Response, Error>) -> Void) {
        // fetch and parse response.
        fetch(method: method,
              url: Result { try endpoint.url() },
              body: body,
              headers: headers ?? [:],
              delay: delay) { [weak self] in
                guard let handler = self?.handler else { return completion(.failure(GenericError.weakObjectReleased)) }
                // consider response.
                let result = $0.flatMap { data, response -> Result<Response, Error> in
                    do {
                        guard let data = data, !options.contains(.validateResponse) || response?.statusCode == 200 else {
                            throw GenericError.custom("Invalid response. \(response?.statusCode ?? -1)")
                        }
                        // decode data.
                        if let response = process(try DynamicResponse(data: data)) {
                            return .success(response)
                        }
                        // raise exception.
                        throw GenericError.custom("Invalid response. Processing handler returned `nil`.")
                    } catch { return .failure(error) }
                }
                // notify results.
                if options.contains(.deliverOnResponseQueue) {
                    handler.settings.queues.response.async { completion(result) }
                } else {
                    completion(result)
                }
        }
    }

    // MARK: Fetch
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
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: handler.response?.cookies ?? [])
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
}
