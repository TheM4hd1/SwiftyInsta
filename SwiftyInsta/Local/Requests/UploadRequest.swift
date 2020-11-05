//
//  UploadRequest.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 06/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

// platform-agnostic `Image`.
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

/// An `enum` holding reference to a model that needs uploading.
public enum Upload {
    /// A `Picture` reference.
    public struct Picture {
        /// The image.
        public var image: Image
        /// The caption.
        public var caption: String
        /// Turn off comments.
        public var disableComments: Bool
        /// The size.
        public var size: CGSize

        /// Init.
        public init(image: Image, caption: String, disableComments: Bool, size: CGSize) {
            self.image = image
            self.caption = caption
            self.size = size
            self.disableComments = disableComments
        }
    }
    /// An `Album` reference.
    public struct Album {
        /// The image.
        public var images: [Image]
        /// The caption.
        public var caption: String
        /// Turn off comments.
        public var disableComments: Bool

        /// Init.
        public init(images: [Image], caption: String, disableComments: Bool) {
            self.images = images
            self.caption = caption
            self.disableComments = disableComments
        }
    }
    /// A `Video` reference.
    public struct Video {
        /// The thumbnail
        public var thumbnail: Image
        /// The video.
        public var data: Data
        /// The caption.
        public var caption: String
        /// Is audio muted.
        public var isAudioMuted: Bool
        /// The size.
        public var size: CGSize
        /// Turn off comments.
        public var disableComments: Bool

        /// Init.
        public init(thumbnail: Image,
                    data: Data,
                    caption: String,
                    isAudioMuted: Bool,
                    size: CGSize,
                    disableComments: Bool) {
            self.thumbnail = thumbnail
            self.data = data
            self.caption = caption
            self.isAudioMuted = isAudioMuted
            self.size = size
            self.disableComments = disableComments
        }
    }

    /// A photo.
    case picture(Picture)
    /// A video.
    case video(Video)
}

public extension User {
    /// User `Tag`.
    struct Tag: Codable {
        enum CodingKeys: CodingKey {
            case userId, position
        }

        /// The user id.
        public let userId: Int
        /// The position.
        public let position: CGPoint

        /// Init.
        public init(userId: Int, position: CGPoint) {
            self.userId = userId
            self.position = position
        }

        // MARK: Codable
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.userId = try container.decode(Int.self, forKey: .userId)
            let offsets = try container.decode([Double].self, forKey: .position)
            self.position = CGPoint(x: offsets.first ?? 0, y: offsets.last ?? 0)
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userId, forKey: .userId)
            try container.encode([position.x, position.y], forKey: .position)
        }
    }
    /// User `Tags`.
    struct Tags: Codable {
        enum CodingKeys: String, CodingKey {
            case adding = "in", removing = "removed"
        }

        /// `Tag`s in the picture.
        public let adding: [Tag]
        /// Removed `userId`s.
        public let removing: [Int]
    }
}
