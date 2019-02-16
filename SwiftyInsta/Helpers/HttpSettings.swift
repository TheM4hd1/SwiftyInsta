//
//  HttpSettings.swift
//  SwiftyInsta
//
//  Created by Mahdi on 2/5/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public class HttpSettings {
    
    static let shared = HttpSettings()
    private init() {
        
    }
    
    private var headers: [String: String] = [:]
    
    /// Any existing value for the field is replaced by the new value
    func addValue(_ value: String, forHTTPHeaderField field: String) {
        headers.updateValue(value, forKey: field)
    }
    
    func getHeaders() -> [String: String] {
        return headers
    }
}
