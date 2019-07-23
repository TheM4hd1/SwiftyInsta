//
//  TwoFactorEnums.swift
//  SwiftyInsta
//
//  Created by Mahdi on 1/31/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public enum VerificationResponse {
    case codeSent
    case failed
    case unknown
}

public enum ChallengeVerificationResponse {
    case accepted
    case checkpointDismiss
    case incorrect
    case loginFailed
    case noRedirect
    case unknown
}

public enum TwofactorVerificationResponse {
    case invalidCode
    case success
    case failed
    case unknown
}
