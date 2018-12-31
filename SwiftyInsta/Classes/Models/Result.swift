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

public struct Result<Element>: ResultProtocol {
    public typealias type = Element
    public var isSucceeded: Bool
    public var info: ResultInfo
    public var value: type?
    
    public init(isSucceeded: Bool, info: ResultInfo, value: type?) {
        self.isSucceeded = isSucceeded
        self.info = info
        self.value = value
    }
}

public struct Return {
    public static func fail<T>(error: Error?, response: ResponseTypes, value: T?) -> Result<T> {
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
    
    public static func success<T>(value: T?) -> Result<T> {
        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
        let result = Result<T>.init(isSucceeded: true, info: info, value: value)
        return result
    }
}
