//
//  LoginBaseResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct LoginBaseResponseModel: Codable {
    var message: String?
    var invalidCredentials: Bool?
    var errorType: String?
    var errorTitle: String?
    var status: String?
    var twoFactorRequired: Bool?
    var twoFactorInfo: TwoFactorLoginInfoModel?
    var checkpointChallengeRequired: Bool?
    var challenge: ChallengeModel?
}
