//
//  HandlerSettings.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

class HandlerSettings {
    static let shared = HandlerSettings()
    
    private init() {
        
    }
    
    var httpHelper: HttpHelper?
    var delay: DelayModel?
    var user: SessionStorage?
    var device: AndroidDeviceModel?
    var request: RequestMessageModel?
    var twoFactor: TwoFactorLoginInfoModel?
    var challenge: ChallengeModel?
    var queue: DispatchQueue?
    var isUserAuthenticated: Bool?
}
