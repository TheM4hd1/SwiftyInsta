//
//  PhoneVerificationSettingsModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct PhoneVerificationSettingsModel: Codable {
    var maxSmsCount: Int
    var resendSmsDelaySec: Int
    var robocallAfterMaxSms: Bool
    var robocallCountDownTime: Int
    
    static func empty() -> PhoneVerificationSettingsModel {
        return PhoneVerificationSettingsModel(
            maxSmsCount: 0,
            resendSmsDelaySec: 0,
            robocallAfterMaxSms: false,
            robocallCountDownTime: 0
        )
    }
}
