//
//  LoginBaseResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct LoginBaseResponseModel: Codable, BaseStatusResponseProtocol{
    public var message: String?
    public var invalidCredentials: Bool?
    public var errorType: String?
    public var errorTitle: String?
    public var status: String?
    public var twoFactorRequired: Bool?
    public var twoFactorInfo: TwoFactorLoginInfoModel?
    public var checkpointChallengeRequired: Bool?
    public var challenge: ChallengeModel?
    
    public init(message: String?, invalidCredentials: Bool?, errorType: String?, errorTitle: String?, status: String?, twoFactorRequired: Bool?, twoFactorInfo: TwoFactorLoginInfoModel?, checkpointChallengeRequired: Bool?, challenge: ChallengeModel?) {
        self.message = message
        self.invalidCredentials = invalidCredentials
        self.errorType = errorType
        self.errorTitle = errorTitle
        self.status = status
        self.twoFactorInfo = twoFactorInfo
        self.twoFactorRequired = twoFactorRequired
        self.checkpointChallengeRequired = checkpointChallengeRequired
        self.challenge = challenge
    }
}
