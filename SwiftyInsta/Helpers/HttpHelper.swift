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
    var configuration: URLSessionConfiguration
    var session: URLSession
    
    init(config: URLSessionConfiguration) {
        configuration = config
        session = URLSession(configuration: config)
    }
    
    func sendRequest(method: HTTPMethods, url: URL, body: [String: Any], header: [String: String], completion: @escaping completionHandler) {
        
    }
    
    func sendRequest(request: URLRequest, completion: @escaping completionHandler) {
        
    }
    
    func getDefaultRequest(for url: URL, method: HTTPMethods, device: AndroidDeviceModel) {
        
    }
    
    fileprivate func addHeaders(to: inout URLRequest, header: [String: String]) {
        
    }
    
    fileprivate func addBody(to: inout URLRequest, body: [String: Any]) {
        
    }
}
