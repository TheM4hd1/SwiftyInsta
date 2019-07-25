//
//  LoginBaseResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct LoginBaseResponseModel: Codable, BaseStatusResponseProtocol {
    var message: String?
    var invalidCredentials: Bool?
    var errorType: String?
    var errorTitle: String?
    var status: String?
    var twoFactorRequired: Bool?
    var twoFactorInfo: TwoFactorLoginInfoModel?
    var checkpointChallengeRequired: Bool?
    var challenge: ChallengeModel?

    init(message: String?,
         invalidCredentials: Bool?,
         errorType: String?,
         errorTitle: String?,
         status: String?,
         twoFactorRequired: Bool?,
         twoFactorInfo: TwoFactorLoginInfoModel?,
         checkpointChallengeRequired: Bool?,
         challenge: ChallengeModel?) {
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
