//
//  Result.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol ResultProtocol {
    associatedtype type
    var isSucceeded: Bool { get }
    var info: ResultInfo { get }
}

struct Result<Element>: ResultProtocol {
    typealias type = Element
    var isSucceeded: Bool
    var info: ResultInfo
    var value: type?
}

struct Return {
    static func fail<T>(error: Error?, response: ResponseTypes, value: T?) -> Result<T> {
        var _error: Error
        if let error = error {
            _error = error
        } else {
            _error = CustomErrors.noError
        }
        
        let info = ResultInfo.init(error: _error, message: _error.localizedDescription, responseType: response)
        let result = Result<T>.init(isSucceeded: false, info: info, value: value)
        return result
    }
    
    static func success<T>(value: T?) -> Result<T> {
        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
        let result = Result<T>.init(isSucceeded: true, info: info, value: value)
        return result
    }
}
