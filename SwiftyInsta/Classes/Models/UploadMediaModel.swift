//
//  UploadMediaModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/16/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol UploadMediaProtocol {
    var image: UIImage {get}
    var caption: String {get}
    var width: Int {get}
    var height: Int {get}
}

struct InstaPhoto: UploadMediaProtocol {
    var image: UIImage
    var caption: String
    var width: Int
    var height: Int
}

struct InstaVideo: UploadMediaProtocol {
    var image: UIImage
    var caption: String
    var width: Int
    var height: Int
    var type: Int
}

struct UploadPhotoResponse: Codable, BaseStatusResponseProtocol {
    var media: MediaModel?
    var uploadId: String?
    var status: String?
}

struct ConfigurePhotoModel: Codable {
    let _uuid: String
    let _uid: Int
    let _csrftoken: String
    let media_folder: String
    let source_type: String
    let caption: String
    let upload_id: String
    let device: ConfigureDevice
    let edits: ConfigureEdits
    let extras: ConfigureExtras
}

struct ConfigureDevice: Codable {
    let manufacturer: String
    let model: String
    let android_version: String
    let android_release: String
}

struct ConfigureEdits: Codable {
    let crop_original_size: [Int]
    let crop_center: [Double]
    let crop_zoom: Int
}

struct ConfigureExtras: Codable {
    let source_width: Int
    let source_height: Int
}
