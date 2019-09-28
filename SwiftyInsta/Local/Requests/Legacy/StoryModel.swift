//
//  StoryModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ConfigureStoryUploadModel: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case sourceType, caption, uploadId, disableComments, configureMode, cameraPosition
    }

    public var uuid: String
    public var uid: String
    public var csrfToken: String
    public var sourceType: String
    public var caption: String
    public var uploadId: String
    //var edits
    public var disableComments: Bool
    public var configureMode: Int
    public var cameraPosition: String

    public init(uuid: String,
                uid: String,
                csrfToken: String,
                sourceType: String,
                caption: String,
                uploadId: String,
                disableComments: Bool,
                configureMode: Int,
                cameraPosition: String) {
        self.uuid = uuid
        self.uid = uid
        self.csrfToken = csrfToken
        self.sourceType = sourceType
        self.caption = caption
        self.uploadId = uploadId
        self.disableComments = disableComments
        self.configureMode = configureMode
        self.cameraPosition = cameraPosition
    }
}

public struct SeenStory: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case containerModule, reels, reelMediaSkipped, liveVods, liveVodsSkipped, nuxes, nuxesSkipped
    }

    let uuid: String
    let uid: String
    let csrfToken: String
    let containerModule: String
    let reels: [String: [String]]
    let reelMediaSkipped: [String: String]
    let liveVods: [String: String]
    let liveVodsSkipped: [String: String]
    let nuxes: [String: String]
    let nuxesSkipped: [String: String]
}
