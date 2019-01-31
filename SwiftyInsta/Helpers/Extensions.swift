//
//  Extensions.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/19/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension Array where Element: HTTPCookie {
    func toCookieData() -> [Data] {
        var cookies = [Data]()
        for cookie in self {
            if let cookieData = cookie.convertToData() {
                cookies.append(cookieData)
            }
        }
        
        return cookies
    }
    
    func getInstagramCookies() -> [HTTPCookie]? {
        if let cookies = try? HTTPCookieStorage.shared.cookies(for: URLs.getInstagramCookieUrl()) {
            return cookies
        }
        
        return [HTTPCookie]()
    }
}

extension HTTPCookie {
    fileprivate func save(cookieProperties: [HTTPCookiePropertyKey : Any]) -> Data {
        let data = NSKeyedArchiver.archivedData(withRootObject: cookieProperties)
        return data
    }
    
    static fileprivate func loadCookieProperties(from data: Data) -> [HTTPCookiePropertyKey : Any]? {
        let unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: data)
        return unarchivedDictionary as? [HTTPCookiePropertyKey : Any]
    }
    
    static func loadCookie(using data: Data?) -> HTTPCookie? {
        guard let data = data, let properties = loadCookieProperties(from: data) else {
            return nil
        }
        
        return HTTPCookie(properties: properties)
    }
    
    func convertToData() -> Data? {
        guard let properties = self.properties else {
            return nil
        }
        
        return save(cookieProperties: properties)
    }
}
