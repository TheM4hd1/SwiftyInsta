//
//  UploadMedia.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/16/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ConfigurePhoto: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case  sourceType, caption, uploadId, edits, isStoriesDraft,
             clientTimestamp, timezoneOffset, cameraPosition, videoSubtitlesEnabled,
             disableComments, waterfallId, geotagEnabled, deviceId, containerModule
    }

    let isStoriesDraft: Bool
    let clientTimestamp: String
    let csrfToken: String
    let timezoneOffset: String
    let edits: ConfigureEdits
    let uuid: String
    let uid: Int
    let cameraPosition: String
    let videoSubtitlesEnabled: Bool
    let sourceType: String
    let disableComments: Bool
    let waterfallId: String
    let geotagEnabled: Bool
    let uploadId: String
    let deviceId: String
    let containerModule: String
    let caption: String
}

struct ConfigureEdits: Codable {
    let cropOriginalSize: [Int]
    let cropCenter: [Double]
    let cropZoom: Int
}

struct ConfigurePhotoAlbum: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case caption, clientSidecarId, geotagEnabled, disableComments,
             childrenMetadata, deviceId, waterfallId, timezoneOffset, clientTimestamp
    }

    let uuid: String
    let uid: Int
    let csrfToken: String
    let caption: String
    let clientSidecarId: String
    let geotagEnabled: Bool
    let disableComments: Bool
    let deviceId: String
    let waterfallId: String
    let timezoneOffset: String
    let clientTimestamp: String
    let childrenMetadata: [ConfigureChildren]
}

struct ConfigureChildren: Codable {
    let uploadId: String
    let disableComments: Bool
    let sourceType: String
    let isStoriesDraft: Bool
    let allowMultiConfigures: Bool
    let cameraPosition: String
    let geotagEnabled: Bool
}

struct ConfigureVideo: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case caption, uploadId, sourceType, cameraPosition, disableComments,
             posterFrameIndex, audioMuted, deviceId, waterfallId, clientTimestamp, timezoneOffset
    }

    let uuid: String
    let uid: String
    let sourceType: String
    let deviceId: String
    let csrfToken: String
    let waterfallId: String
    let clientTimestamp: String
    let audioMuted: Bool
    let caption: String
    let uploadId: String
    let cameraPosition: String
    let timezoneOffset: String
    let posterFrameIndex: Int
    let disableComments: Bool
}
