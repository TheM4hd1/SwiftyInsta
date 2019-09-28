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

struct ConfigurePhotoModel: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case mediaFolder, sourceType, caption, uploadId, device, edits, extras
    }

    let uuid: String
    let uid: Int
    let csrfToken: String
    let mediaFolder: String
    let sourceType: String
    let caption: String
    let uploadId: String
    let device: ConfigureDevice
    let edits: ConfigureEdits
    let extras: ConfigureExtras
}

struct ConfigureDevice: Codable {
    let manufacturer: String
    let model: String
    let androidVersion: String
    let androidRelease: String
}

struct ConfigureEdits: Codable {
    let cropOriginalSize: [Int]
    let cropCenter: [Double]
    let cropZoom: Int
}

struct ConfigureExtras: Codable {
    let sourceWidth: Int
    let sourceHeight: Int
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
        case caption, uploadId, sourceType, cameraPosition, extra, clips, posterFrameIndex, audioMuted, filterType, videoResult
    }

    let caption: String
    let uploadId: String
    let sourceType: String
    let cameraPosition: String
    let extra: ConfigureExtras
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
