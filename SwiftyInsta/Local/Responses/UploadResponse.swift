//
//  UploadResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 06/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public extension Upload {
    struct Response {
        /// A `struct` holding reference to a successful `Upload.picture`.
        public struct Picture: Codable, StatusEnforceable {
            /// The media.
            public var media: Media?
            /// The upload id.
            public var uploadId: String?
            /// The status.
            public var status: String?
        }
        /// A `struct` holding reference to a successful `Upload.video`.
        public struct Video: Codable, StatusEnforceable {
            /// The urls.
            public var urls: [URL]
            /// The upload id.
            public var uploadId: String?
            /// The status.
            public var status: String?
        }
    }
}
public extension Upload.Response.Video {
    /// The `Video` url structure.
    public struct URL: Codable {
        /// The url.
        public let url: String?
        /// The job.
        public let job: String?
        /// The expiration.
        public let expires: Double?
    }
    enum CodingKeys: String, CodingKey {
        case urls = "videoUploadUrls", uploadId, status
    }
}
