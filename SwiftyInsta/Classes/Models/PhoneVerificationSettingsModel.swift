//
//  PhoneVerificationSettingsModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct PhoneVerificationSettingsModel: Codable {
    public var maxSmsCount: Int
    public var resendSmsDelaySec: Int
    public var robocallAfterMaxSms: Bool
    public var robocallCountDownTimeSec: Int
    
    public init(maxSmsCount: Int, resendSmsDelaySec: Int, robocallAfterMaxSms: Bool, robocallCountDownTimeSec: Int) {
        self.maxSmsCount = maxSmsCount
        self.resendSmsDelaySec = resendSmsDelaySec
        self.robocallAfterMaxSms = robocallAfterMaxSms
        self.robocallCountDownTimeSec = robocallCountDownTimeSec
    }
    
    static func empty() -> PhoneVerificationSettingsModel {
        return PhoneVerificationSettingsModel(
            maxSmsCount: 0,
            resendSmsDelaySec: 0,
            robocallAfterMaxSms: false,
            robocallCountDownTimeSec: 0
        )
    }
}
