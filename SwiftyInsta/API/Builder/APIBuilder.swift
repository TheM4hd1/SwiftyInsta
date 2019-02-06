//
//  APIBuilder.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol APIBuilderProtocol {
    func setUser(user: SessionStorage) -> APIBuilderProtocol
    func setHttpHandler(urlSession: URLSession) -> APIBuilderProtocol
    func setRequestDelay(delay: DelayModel) -> APIBuilderProtocol
    func build() throws -> APIHandlerProtocol
}

public class APIBuilder: APIBuilderProtocol {
    
    private var _delay: DelayModel?
    private var _user: SessionStorage?
    private var _device: AndroidDeviceModel?
    private var _request: RequestMessageModel?
    private var _urlSession: URLSession?
    
    public init() {
        
    }
    
    public func createBuilder() -> APIBuilderProtocol {
        return APIBuilder()
    }
    
    public func setUser(user: SessionStorage) -> APIBuilderProtocol {
        _user = user
        return self
    }
    
    public func setHttpHandler(urlSession: URLSession) -> APIBuilderProtocol {
        _urlSession = urlSession
        return self
    }
    
    public func setRequestDelay(delay: DelayModel) -> APIBuilderProtocol {
        _delay = delay
        return self
    }
    
    public func build() throws -> APIHandlerProtocol {
        guard let user = _user else {
            throw CustomErrors.runTimeError("User auth data must be specified.")
        }
        
        if _request == nil {
            _device = AndroidDeviceGenerator.getRandomAndroidDevice()
            guard let device = _device else {
                throw CustomErrors.runTimeError("Fail to generate random android device.")
            }
            
            _request = RequestMessageModel.init(
                phoneId: device.phoneGuid.uuidString,
                username: user.username,
                guid: device.deviceGuid,
                deviceId: RequestMessageModel.generateDeviceIdFromGuid(guid: device.deviceGuid),
                password: user.password,
                loginAttemptCount: "0"
            )
        }
        
        guard let request = _request else {
            throw CustomErrors.runTimeError("Fail to unwrap request model.")
        }
        
        if request.password.isEmpty {
            _request?.password = user.password
        }
        
        if request.username.isEmpty {
            _request?.username = user.username
        }
        
        if _device == nil && !(request.deviceId.isEmpty) {
            _device = try? AndroidDeviceGenerator.getById(deviceId: request.deviceId)
        }
        
        if _device == nil {
            _device = AndroidDeviceGenerator.getRandomAndroidDevice()
        }
        
        if _delay == nil {
            _delay = DelayModel.init(min: 5, max: 5)
        }
        
        if _urlSession == nil {
            _urlSession = URLSession(configuration: .default)
        }
        
        // We can safely unwrap values.
        return APIHandler(request: _request!, user: user, device: _device!, delay: _delay!, urlSession: _urlSession!)//config: _config!)
    }
}
