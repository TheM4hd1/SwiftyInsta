//
//  MediaHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// **Instagram** accepted `Media`s.
public enum MediaType: String {
    /// Image.
    case image = "1"
    /// Video.
    case video = "2"
    /// Carousel (a.k.a. **album**).
    case carousel = "8"
}

public final class MediaHandler: Handler {
    /// Get user media.
    public func by(user: User.Reference,
                   with paginationParameters: PaginationParameters,
                   updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                   completionHandler: @escaping PaginationCompletionHandler<Media>) {
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache), paginationParameters)
            }
            by(user: .primaryKey(pk),
               with: paginationParameters,
               updateHandler: updateHandler,
               completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.by(user: .primaryKey(user.identity.primaryKey ?? -1),
                               with: paginationParameters,
                               updateHandler: updateHandler,
                               completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load media directly.
            pages.request(Media.self,
                          page: AnyPaginatedResponse.self,
                          with: paginationParameters,
                          endpoint: { Endpoint.Feed.user.user(pk).next($0.nextMaxId) },
                          splice: { $0.rawResponse.items.array?.compactMap(Media.init) ?? [] },
                          update: updateHandler,
                          completion: completionHandler)
        }
    }

    /// Get media info.
    public func info(for mediaId: String, completionHandler: @escaping (Result<Media?, Error>) -> Void) {
        pages.request(Media.self,
                      page: AnyPaginatedResponse.self,
                      with: .init(maxPagesToLoad: 1),
                      endpoint: { _ in Endpoint.Media.info.media(mediaId) },
                      splice: { $0.rawResponse.items.array?.compactMap(Media.init) ?? [] },
                      update: nil,
                      completion: { result, _ in
                        completionHandler(result.map { $0.first })
                      })
    }

    /// Like media.
    public func like(media mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "device_id": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "delivery_class": "organic",
                    "inventory_source": "media_or_ad",
                    "is_carousel_bumped_post": "false",
                    "container_module": "feed_timeline",
                    "carousel_index": "0",
                    "module_name": "feed_timeline",
                    "media_id": mediaId]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Media.like.media(mediaId),
                         body: .payload(body),
                         completion: { completionHandler($0.map { $0.state == .ok }) })
    }

    /// Unlike media.
    public func unlike(media mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Media.unlike.media(mediaId),
                         body: .parameters(body),
                         completion: { completionHandler($0.map { $0.state == .ok }) })
    }

    /// Upload photo.
    public func upload(photo: Upload.Picture, completionHandler: @escaping (Result<Upload.Response.Picture, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)

        #if os(macOS)
        let optionalImageData = photo.image.tiffRepresentation
        #else
        let optionalImageData = photo.image.jpegData(compressionQuality: 1)
        #endif
        guard let imageData = optionalImageData else {
            return completionHandler(.failure(GenericError.custom("Invalid Image.")))
        }

        // swiftlint:disable line_length
        let rUploadParams = "{\"image_compression\":\"{\\\"quality\\\":64,\\\"lib_version\\\":\\\"1676.104000\\\",\\\"ssim\\\":0.99618792533874512,\\\"colorspace\\\":\\\"kCGColorSpaceDeviceRGB\\\",\\\"lib_name\\\":\\\"uikit\\\"}\",\"upload_id\":\"\(uploadId)\",\"xsharing_user_ids\":[],\"media_type\":1}"
        // swiftlint:enable line_length
        let headers = ["Content-Type": "application/octet-stream",
                       "X-Entity-Name": "image.jpeg",
                       "X-Entity-Type": "image/jpeg",
                       "x_fb_photo_waterfall_id": UUID.init().uuidString.md5(),
                       "X-Entity-Length": "\(imageData.count)",
                       "Content-Length": "\(imageData.count)",
                       "X-Instagram-Rupload-Params": rUploadParams,
                       "Accept-Encoding": "gzip, deflate",
                       "Offset": "0",
                       "IG-U-Ds-User-ID": storage.dsUserId]
        requests.request(Upload.Response.Picture.self,
                         method: .post,
                         endpoint: Endpoint.Upload.photo.upload(uploadId.md5()),
                         body: .data(imageData),
                         headers: headers,
                         options: .deliverOnResponseQueue) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.weakObjectReleased))
            }
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success(let decoded):
                guard let uploadId = decoded.uploadId else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.unknown))
                    }
                }
                // configure
                me.configure(photo: photo,
                             with: uploadId,
                             caption: photo.caption,
                             completionHandler: completionHandler)
            }
        }
    }

    /// Set up photo.
    func configure(photo: Upload.Picture,
                   with uploadId: String,
                   caption: String,
                   completionHandler: @escaping (Result<Upload.Response.Picture, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let device = handler.settings.device
        guard let user = storage.user else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        let waterfallId = UUID().uuidString
        let timestamp = String(Date().millisecondsSince1970 / 1000)
        let configureEdits = ConfigureEdits.init(cropOriginalSize: [Int(photo.size.width),
                                                                    Int(photo.size.height)],
                                                 cropCenter: [0.0, -0.0],
                                                 cropZoom: 1)
        let configure = ConfigurePhoto(isStoriesDraft: false,
                                       clientTimestamp: timestamp,
                                       csrfToken: storage.csrfToken,
                                       timezoneOffset: "\(TimeZone.current.secondsFromGMT())",
                                       edits: configureEdits,
                                       uuid: device.deviceGuid.uuidString,
                                       uid: user.identity.primaryKey ?? -1,
                                       cameraPosition: "unknown",
                                       videoSubtitlesEnabled: false,
                                       sourceType: "library",
                                       disableComments: photo.disableComments,
                                       waterfallId: waterfallId,
                                       geotagEnabled: false,
                                       uploadId: uploadId,
                                       deviceId: device.deviceGuid.uuidString,
                                       containerModule: "photo_edit",
                                       caption: caption)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(configure), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        // prepare body.
        let signature = "SIGNATURE.\(payload)"
        let body: [String: Any] = [
            Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
        ]

        requests.request(Upload.Response.Picture.self,
                         method: .post,
                         endpoint: Endpoint.Media.configure,
                         body: .parameters(body),
                         completion: completionHandler)
    }

    /// Upload photo album
    public func upload(album: Upload.Album,
                       completionHandler: @escaping (Result<Upload.Response.Album, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        var uploadIds: [String] = []
        let group = DispatchGroup()
        DispatchQueue.global().async { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.weakObjectReleased))
            }
            for photo in album.images {
                group.enter()
                let uploadId = String(Date().millisecondsSince1970 / 1000)
                // swiftlint:disable line_length
                let rUploadParams = "{\"image_compression\":\"{\\\"quality\\\":48,\\\"lib_version\\\":\\\"1676.104000\\\",\\\"ssim\\\":0.99717170000076294,\\\"colorspace\\\":\\\"kCGColorSpaceDeviceRGB\\\",\\\"lib_name\\\":\\\"uikit\\\"}\",\"upload_id\":\"\(uploadId)\",\"xsharing_user_ids\":[],\"is_sidecar\":\"1\",\"media_type\":1}"
                #if os(macOS)
                let optionalImageData = photo.tiffRepresentation
                #else
                let optionalImageData = photo.jpegData(compressionQuality: 1)
                #endif
                guard let imageData = optionalImageData else {
                    return completionHandler(.failure(GenericError.custom("Invalid Image.")))
                }
                let headers = ["Content-Type": "application/octet-stream",
                               "X-Entity-Name": "image.jpeg",
                               "X-Entity-Type": "image/jpeg",
                               "x_fb_photo_waterfall_id": UUID.init().uuidString.md5(),
                               "X-Entity-Length": "\(imageData.count)",
                               "Content-Length": "\(imageData.count)",
                               "X-Instagram-Rupload-Params": rUploadParams,
                               "Accept-Encoding": "gzip, deflate",
                               "Offset": "0",
                               "IG-U-Ds-User-ID": storage.dsUserId]

                me.requests.request(Upload.Response.Picture.self,
                                    method: .post,
                                    endpoint: Endpoint.Upload.photo.upload(uploadId.md5()),
                                    body: .data(imageData),
                                    headers: headers,
                                    options: .deliverOnResponseQueue) {
                    switch $0 {
                    case .failure(let error):
                        handler.settings.queues.response.async {
                            completionHandler(.failure(error))
                        }
                    case .success(let decoded):
                        guard let uploadId = decoded.uploadId else {
                            return handler.settings.queues.response.async {
                                completionHandler(.failure(GenericError.unknown))
                            }
                        }
                        uploadIds.append(uploadId)
                        group.leave()
                    }
                }
                group.wait()
            }
            // configure album
            me.configureAlbum(album: album,
                              with: uploadIds,
                              completionHandler: completionHandler)
        }
    }

    /// Set up album.
    func configureAlbum(album: Upload.Album,
                        with uploadIds: [String],
                        completionHandler: @escaping (Result<Upload.Response.Album, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let device = handler.settings.device
        guard let user = storage.user else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        let childrens = uploadIds.map { ConfigureChildren.init(uploadId: $0,
                                                               disableComments: album.disableComments,
                                                               sourceType: "library",
                                                               isStoriesDraft: false,
                                                               allowMultiConfigures: false,
                                                               cameraPosition: "unknown",
                                                               geotagEnabled: false) }
        let timestamp = String(Date().millisecondsSince1970 / 1000)
        let sidecarId = String(Date().millisecondsSince1970 / 1000)
        let configure = ConfigurePhotoAlbum(uuid: device.deviceGuid.uuidString,
                                            uid: user.identity.primaryKey ?? -1,
                                            csrfToken: storage.csrfToken,
                                            caption: album.caption,
                                            clientSidecarId: sidecarId,
                                            geotagEnabled: false,
                                            disableComments: album.disableComments,
                                            deviceId: device.deviceGuid.uuidString,
                                            waterfallId: UUID().uuidString,
                                            timezoneOffset: "\(TimeZone.current.secondsFromGMT())",
                                            clientTimestamp: timestamp,
                                            childrenMetadata: childrens)
        // prepare body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(configure), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        let signature = "SIGNATURE.\(payload)"
        let body: [String: Any] = [
            Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
        ]
        requests.request(Upload.Response.Album.self,
                         method: .post,
                         endpoint: Endpoint.Media.configureAlbum,
                         body: .parameters(body),
                         completion: completionHandler)
    }

    // Make sure file is valid (correct format, codecs, width, height and aspect ratio)
    // also its important to provide fileName.extenstion in InstaVideo
    // to convert video to data you need to pass file's URL to Data.init(contentsOf: URL)
    public func upload(video: Upload.Video,
                       completionHandler: @escaping (Result<Upload.Response.Video, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)

        // swiftlint:disable line_length
        let rVideoUploadParams = "{\"content_tags\":\"infinite-gop,has-crop,square,source-type-library\",\"upload_media_height\":720,\"upload_id\":\"\(uploadId)\",\"media_type\":2,\"xsharing_user_ids\":[],\"upload_media_width\":720,\"upload_media_duration_ms\":6800}"
        // swiftlint:enable line_length
        let headers = ["Content-Type": "application/octet-stream",
                       "X-Entity-Name": "video.mp4",
                       "X-Entity-Type": "video/mpeg",
                       "X_FB_VIDEO_WATERFALL_ID": UUID.init().uuidString.md5(),
                       "X-Entity-Length": "\(video.data.count)",
                       "Content-Length": "\(video.data.count)",
                       "X-Instagram-Rupload-Params": rVideoUploadParams,
                       "Accept-Encoding": "gzip, deflate",
                       "Offset": "0",
                       "IG-U-Ds-User-ID": storage.dsUserId]
        // upload video
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Upload.video.upload(UUID().uuidString),
                         body: .data(video.data),
                         headers: headers,
                         options: .deliverOnResponseQueue) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.weakObjectReleased))
            }
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success(let decoded):
                if decoded.state == .ok {
                    // upload thumbnail
                    me.upload(thumbnail: video.thumbnail, with: uploadId) {
                        switch $0 {
                        case .failure(let error):
                            handler.settings.queues.response.async {
                                completionHandler(.failure(error))
                            }
                        case .success(let uploadId):
                            // finish upload
                            me.finish(video: video,
                                      with: uploadId,
                                      completionHandler: completionHandler)
                        }
                    }
                } else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.unknown))
                    }
                }
            }
        }
    }

    /// upload video thumbnail.
    func upload(thumbnail: Image,
                with uploadId: String,
                completionHandler: @escaping (Result<String, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        #if os(macOS)
        let optionalImageData = thumbnail.tiffRepresentation
        #else
        let optionalImageData = thumbnail.jpegData(compressionQuality: 1)
        #endif
        guard let imageData = optionalImageData else {
            return completionHandler(.failure(GenericError.custom("Invalid Image.")))
        }

        // swiftlint:disable line_length
        let rThumbnailUploadParams =
            "{\"image_compression\":\"{\\\"quality\\\":65,\\\"lib_version\\\":\\\"1676.104000\\\",\\\"ssim\\\":0.98724246025085449,\\\"colorspace\\\":\\\"kCGColorSpaceDeviceRGB\\\",\\\"lib_name\\\":\\\"uikit\\\"}\",\"upload_id\":\"\(uploadId)\",\"xsharing_user_ids\":[],\"content_tags\":\"infinite-gop,has-crop,square,source-type-library\",\"media_type\":2}"
        // swiftlint:enable line_length
        let headers = ["Content-Type": "application/octet-stream",
                       "X-Entity-Name": "image.jpeg",
                       "X-Entity-Type": "image/jpeg",
                       "x_fb_photo_waterfall_id": UUID.init().uuidString.md5(),
                       "X-Entity-Length": "\(imageData.count)",
                       "Content-Length": "\(imageData.count)",
                       "X-Instagram-Rupload-Params": rThumbnailUploadParams,
                       "Accept-Encoding": "gzip, deflate",
                       "Offset": "0",
                       "IG-U-Ds-User-ID": storage.dsUserId]
        requests.request(Upload.Response.Picture.self,
                         method: .post,
                         endpoint: Endpoint.Upload.photo.upload(uploadId.md5()),
                         body: .data(imageData),
                         headers: headers,
                         options: .deliverOnResponseQueue) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.weakObjectReleased))
            }
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success(let decoded):
                guard let uploadId = decoded.uploadId else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.unknown))
                    }
                }
                completionHandler(.success(uploadId))
            }
        }
    }

    /// Set up video.
    func configure(video: Upload.Video,
                   with uploadId: String,
                   completionHandler: @escaping (Result<Upload.Response.Video, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let device = handler.settings.device
        let waterfallId = UUID().uuidString
        let timestamp = String(Date().millisecondsSince1970 / 1000)
        let configure = ConfigureVideo(uuid: device.deviceGuid.uuidString,
                                       uid: storage.dsUserId,
                                       sourceType: "library",
                                       deviceId: device.deviceGuid.uuidString,
                                       csrfToken: storage.csrfToken,
                                       waterfallId: waterfallId,
                                       clientTimestamp: timestamp,
                                       audioMuted: video.isAudioMuted,
                                       caption: video.caption,
                                       uploadId: uploadId,
                                       cameraPosition: "unknown",
                                       timezoneOffset: "\(TimeZone.current.secondsFromGMT())",
                                       posterFrameIndex: 0,
                                       disableComments: video.disableComments)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(configure), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        // prepare body.
        let signature = "SIGNATURE.\(payload)"
        let body: [String: Any] = [
            Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
        ]

        requests.request(Upload.Response.Video.self,
                         method: .post,
                         endpoint: Endpoint.Media.configure,
                         body: .parameters(body),
                         completion: completionHandler)
    }

    /// Finish video upload.
    func finish(video: Upload.Video,
                with uploadId: String,
                completionHandler: @escaping (Result<Upload.Response.Video, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_csrftoken": storage.csrfToken,
                    "_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "upload_id": uploadId]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Upload.finish,
                         body: .payload(body)) { [weak self] in
            guard let me = self, let handler = me.handler else {
                return completionHandler(.failure(GenericError.weakObjectReleased))
            }
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success(let decoded):
                if decoded.state == .ok {
                    // configure
                    me.configure(video: video,
                                 with: uploadId,
                                 completionHandler: completionHandler)
                } else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.unknown))
                    }
                }
            }
        }
    }

    /// Delete media.
    public func delete(media mediaId: String,
                       with type: MediaType,
                       completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]

        requests.request(Bool.self,
                         method: .post,
                         endpoint: Endpoint.Media.delete.media(mediaId).type(type),
                         body: .payload(body),
                         process: { $0.didDelete.bool ?? false },
                         completion: completionHandler)
    }

    /// Edit media.
    public func edit(media mediaId: String,
                     caption: String,
                     tags: User.Tags,
                     completionHandler: @escaping (Result<Media, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let tagPayload = try? String(data: encoder.encode(tags), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }

        let deviceId = handler!.settings.device.deviceGuid.uuidString
        // prepare body
        let content = ["_uuid": deviceId,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "device_id": deviceId,
                       "caption_text": caption,
                       "container_module": "edit_post",
                       "usertags": tagPayload]
        guard let payload = try? String(data: encoder.encode(content), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        let signature = "SIGNATURE.\(payload)"
        let body: [String: Any] = [
            Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        ]

        requests.request(Media.self,
                         method: .post,
                         endpoint: Endpoint.Media.edit.media(mediaId),
                         body: .parameters(body),
                         completion: completionHandler)
    }

    /// Get media likers.
    public func likers(ofMedia mediaId: String,
                       with paginationParameters: PaginationParameters,
                       updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                       completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.request(User.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Media.likers.media(mediaId).next($0.nextMaxId) },
                      splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Get media permalink.
    public func permalink(ofMedia mediaId: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        requests.request(String.self,
                         method: .get,
                         endpoint: Endpoint.Media.permalink.media(mediaId),
                         process: { $0.permalink.string },
                         completion: completionHandler)
    }
}
