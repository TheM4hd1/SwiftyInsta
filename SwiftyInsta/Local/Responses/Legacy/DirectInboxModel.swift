//
//  DirectInboxModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/12/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct DirectPayloadModel: Codable {
    public var clientContext: String?
    public var itemId: String?
    public var timestamp: String?
    public var threadId: String?

    public init(clientContext: String?, itemId: String?, timestamp: String?, threadId: String?) {
        self.clientContext = clientContext
        self.itemId = itemId
        self.timestamp = timestamp
        self.threadId = threadId
    }
}

public struct DirectSendMessageResponseModel: Codable, StatusEnforceable {
    var status: String?
    var statusCode: String?
    var action: String?
    var payload: DirectPayloadModel

    public init(status: String?, statusCode: String?, action: String?, payload: DirectPayloadModel) {
        self.status = status
        self.statusCode = statusCode
        self.action = action
        self.payload = payload
    }
}
