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
        public struct Picture: ParsedResponse, StatusEnforceable {
            /// Init with `rawResponse`.
            public init?(rawResponse: DynamicResponse) {
                guard rawResponse != .none else { return nil }
                self.rawResponse = rawResponse
            }

            /// The `rawResponse`.
            public let rawResponse: DynamicResponse

            /// The media.
            public var media: Media? { return Media(rawResponse: rawResponse.media) }
            /// The upload id.
            public var uploadId: String? { return rawResponse.uploadId.string }
            /// The status.
            public var status: String? { return rawResponse.status.string }

            // MARK: Codable
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawResponse.data())
            }
        }
        /// A `struct` holding reference to a successful `Upload.picture`.
        public struct Album: ParsedResponse, StatusEnforceable {
            /// Init with `rawResponse`.
            public init?(rawResponse: DynamicResponse) {
                guard rawResponse != .none else { return nil }
                self.rawResponse = rawResponse
            }

            /// The `rawResponse`.
            public let rawResponse: DynamicResponse

            /// The media.
            public var media: Media? { return Media(rawResponse: rawResponse.media) }
            /// The upload id.
            public var sidecarId: String? { return rawResponse.clientSidecarId.string }
            /// The status.
            public var status: String? { return rawResponse.status.string }

            // MARK: Codable
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawResponse.data())
            }
        }
        /// A `struct` holding reference to a successful `Upload.video`.
        public struct Video: ParsedResponse, StatusEnforceable {
            /// Init with `rawResponse`.
            public init?(rawResponse: DynamicResponse) {
                guard rawResponse != .none else { return nil }
                self.rawResponse = rawResponse
            }

            /// The `rawResponse`.
            public let rawResponse: DynamicResponse

            /// The media.
            public var media: Media? { return Media(rawResponse: rawResponse.media) }
            /// The upload id.
            public var uploadId: String? { return rawResponse.uploadId.string }
            /// The status.
            public var status: String? { return rawResponse.status.string }

            // MARK: Codable
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawResponse.data())
            }
        }
        /// A `struct` holding reference to a successful `Upload.offset`
        public struct Offset: PaginatedResponse, StatusEnforceable {
            /// init with `rawResponse`
            public init?(rawResponse: DynamicResponse) {
                guard rawResponse != .none else { return nil }
                self.rawResponse = rawResponse
            }

            /// The `rawResponse`.
            public let rawResponse: DynamicResponse

            public var offset: Int? { return rawResponse.offset.int }
            /// The status.
            public var status: String? { return rawResponse.status.string }

            // MARK: Codable
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
            }
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawResponse.data())
            }
        }
    }
}
public extension Upload.Response.Video {
    /// The `Video` url structure.
    struct URL: ParsedResponse {
        /// Init with `rawResponse`.
        public init?(rawResponse: DynamicResponse) {
            guard rawResponse != .none else { return nil }
            self.rawResponse = rawResponse
        }

        /// The `rawResponse`.
        public let rawResponse: DynamicResponse

        /// The url.
        public var url: String? { return rawResponse["url"].string }
        /// The job.
        public var job: String? { return rawResponse.job.string }
        /// The expiration.
        public var expires: Double? { return rawResponse.expires.double }

        // MARK: Codable
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawResponse.data())
        }
    }
}
