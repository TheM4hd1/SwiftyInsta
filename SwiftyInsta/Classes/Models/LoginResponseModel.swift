//
//  LoginResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct CredentialsAuthenticationResponse: Codable {
    var message: String?
    var checkpointUrl: String?
    var lock: Bool?
    var user: Bool?
    var authenticated: Bool?
    var userId: String?
    var fr: String?
    var twoFactorRequired: Bool?
    var twoFactorInfo: TwoFactorInfo?
    var status: String?
}

struct TwoFactorInfo: Codable {
    var username: String?
    var smsTwoFactorOn: Bool?
    var totpTwoFactorOn: Bool?
    var obfuscatedPhoneNumber: String?
    var twoFactorIdentifier: String?
    var phoneVerificationSettings: PhoneVerificationSettings?
}

struct PhoneVerificationSettings: Codable {
    var maxSmsCount: Int?
    var resendSmsDelaySec: Int?
    var robocallAfterMaxSms: Bool?
    var robocallCountDownTimeSec: Int?
}

