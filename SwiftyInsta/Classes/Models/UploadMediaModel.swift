//
//  UploadMediaModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/16/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

#if os(OSX)
    import AppKit
    public typealias Image = NSImage
#elseif os(watchOS)
    import WatchKit
    public typealias Image = UIImage
#else
    import UIKit
    public typealias Image = UIImage
#endif

public protocol UploadMediaProtocol {
    var caption: String {get}
    var width: Int {get}
    var height: Int {get}
}

public struct InstaPhoto: UploadMediaProtocol {
    public var image: Image
    public var caption: String
    public var width: Int
    public var height: Int

    public init(image: Image, caption: String, width: Int, height: Int) {
        self.image = image
        self.caption = caption
        self.width = width
        self.height = height
    }
}

public struct InstaVideo: UploadMediaProtocol {
    public var data: Data
    public var fileName: String
    public var caption: String
    public var audioMuted: Bool
    public var width: Int
    public var height: Int
    public var type: Int

    public init(data: Data, name: String, caption: String, muted: Bool, width: Int, height: Int, type: Int) {
        self.data = data
        self.fileName = name
        self.caption = caption
        self.audioMuted = muted
        self.width = width
        self.height = height
        self.type = type
    }
}

public struct UploadPhotoResponse: Codable, BaseStatusResponseProtocol {
    var media: MediaModel?
    var uploadId: String?
    var status: String?
}

public struct UploadPhotoAlbumResponse: Codable, BaseStatusResponseProtocol {
    var clientSidecarId: String?
    var media: MediaModel?
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

struct UploadVideoResponse: Codable, BaseStatusResponseProtocol {
    let videoUploadUrls: [VideoUploadUrls]?
    let uploadId: String?
    var status: String?
}

struct VideoUploadUrls: Codable {
    let url: String?
    let job: String?
    let expires: Double?
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
