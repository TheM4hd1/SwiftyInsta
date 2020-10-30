//
//  UploadMedia.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/16/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UploadPhotoAlbumResponse: Codable, StatusEnforceable {
    var clientSidecarId: String?
    var media: Media?
    var status: String?
}

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

struct ConfigurePhotoAlbumModel: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case caption, clientSidecarId, geotagEnabled, disableComments, childrenMetadata
    }

    let uuid: String
    let uid: Int
    let csrfToken: String
    let caption: String
    let clientSidecarId: String
    let geotagEnabled: Bool
    let disableComments: Bool
    let childrenMetadata: [ConfigureChildren]
}

struct ConfigureChildren: Codable {
    let sceneCaptureType: String
    let masOptIn: String
    let cameraPosition: String
    let allowMultiConfigures: Bool
    let geotagEnabled: Bool
    let disableComments: Bool
    let sourceType: Int
    let uploadId: String
}

struct ConfigureVideoModel: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case caption, uploadId, sourceType, cameraPosition, clips, posterFrameIndex, audioMuted, filterType, videoResult
    }

    let caption: String
    let uploadId: String
    let sourceType: String
    let cameraPosition: String
    let clips: [ClipsModel]
    let posterFrameIndex: Int
    let audioMuted: Bool
    let filterType: String
    let videoResult: String
    let csrfToken: String
    let uuid: String
    let uid: String
}

struct ClipsModel: Codable {
    let length: Int
    let creationDate: String
    let sourceType: String
    let cameraPosition: String
}
