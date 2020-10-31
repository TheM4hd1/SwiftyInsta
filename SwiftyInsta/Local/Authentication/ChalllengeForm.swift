//
//  ChallengeForm.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ChallengeForm: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
    /// The `stepName` value
    public var name: String? {
        return rawResponse.stepName.string
    }
    /// Suggested methods for receiving `challengeCode`. `EMAIL` or `SMS`
    public var suggestion: [String]? {
        return [rawResponse.stepData.phoneNumber.string ?? "None",
                rawResponse.stepData.email.string ?? "None"].filter { !$0.elementsEqual("None") }
    }
    /// The `bloksAction` value.
    public var bloksAction: String? {
        return rawResponse.bloksAction.string
    }
    /// The `userId` value.
    public var userId: Int? {
        return rawResponse.userId.int
    }
    /// The `nonceCode` value.
    public var code: String? {
        return rawResponse.nonceCode.string
    }
    /// The `challengeContext` value
    public var context: String? {
        return rawResponse.challengeContext.string
    }
}
