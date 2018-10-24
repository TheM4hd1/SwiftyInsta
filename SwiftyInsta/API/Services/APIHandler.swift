//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol APIHandlerProtocol {
    func login(completion: @escaping (Result<LoginResultModel>) -> ())
}

class APIHandler: APIHandlerProtocol {
    
    private var _delay: DelayModel
    private var _user: SessionStorage
    private var _device: AndroidDeviceModel
    private var _request: RequestMessageModel
    private var _httpHelper: HttpHelper
    
    init(request: RequestMessageModel, user: SessionStorage, device: AndroidDeviceModel, delay: DelayModel, config: URLSessionConfiguration) {
        _delay = delay
        _user = user
        _device = device
        _request = request
        _httpHelper = HttpHelper(config: config)
    }
    
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) {
        
    }
}
