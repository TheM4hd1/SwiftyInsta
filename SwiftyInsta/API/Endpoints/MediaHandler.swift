//
//  MediaHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import CryptoSwift
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
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.by(user: .primaryKey(user?.identity.primaryKey ?? -1),
                               with: paginationParameters,
                               updateHandler: updateHandler,
                               completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load media directly.
            pages.parse(Media.self,
                        paginatedResponse: AnyPaginatedResponse.self,
                        with: paginationParameters,
                        at: { try Endpoints.Feed.user.resolving(pk).url(with: ["max_id": $0.nextMaxId]) },
                        processingHandler: { $0.rawResponse.items.array?.map(Media.init) ?? [] },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get media info.
    public func info(for mediaId: String, completionHandler: @escaping (Result<Media?, Error>) -> Void) {
        pages.parse(Media.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: .init(maxPagesToLoad: 1),
                    at: { _ in try Endpoints.Media.info.resolving(mediaId).url() },
                    processingHandler: { $0.rawResponse.items.array?.map(Media.init) ?? [] },
                    updateHandler: nil,
                    completionHandler: { result, _ in
                        completionHandler(result.map { $0.first })
        })
    }

    /// Like media.
    public func like(media mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]

        requests.decode(Status.self,
                        method: .post,
                        url: Result { try Endpoints.Media.like.resolving(mediaId).url() },
                        body: .parameters(body),
                        completionHandler: { completionHandler($0.map { $0.state == .ok }) })
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

        requests.decode(Status.self,
                        method: .post,
                        url: Result { try Endpoints.Media.unlike.resolving(mediaId).url() },
                        body: .parameters(body),
                        completionHandler: { completionHandler($0.map { $0.state == .ok }) })
    }

    /// Upload photo.
    public func upload(photo: Upload.Picture, completionHandler: @escaping (Result<Upload.Response.Picture, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)
        // prepare content.
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
        content.append(string: "\(uploadId)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
        content.append(string: "\(handler.settings.device.deviceGuid.uuidString)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
        content.append(string: "\(storage.csrfToken)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
        content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Transfer-Encoding: binary\n")
        content.append(string: "Content-Type: application/octet-stream\n")
        content.append(string: ["Content-Disposition: form-data; name=photo;",
                                "filename=pending_media_\(uploadId).jpg;",
                                "filename*=utf-8''pending_media_\(uploadId).jpg\n\n"].joined(separator: " "))

        #if os(macOS)
        let optionalImageData = photo.image.tiffRepresentation
        #else
        let optionalImageData = photo.image.jpegData(compressionQuality: 1)
        #endif
        guard let imageData = optionalImageData else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        content.append(imageData)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.decode(Upload.Response.Picture.self,
                        method: .post,
                        url: Result { try Endpoints.Upload.uploadPhoto.url() },
                        body: .data(content),
                        headers: headers,
                        deliverOnResponseQueue: false) { [weak self] in
                            guard let me = self, let handler = me.handler else {
                                return completionHandler(.failure(GenericError.weakObjectReleased))
                            }
                            switch $0 {
                            case .failure(let error):
                                handler.settings.queues.response.async {
                                    completionHandler(.failure(error))
                                }
                            case .success(let decoded):
                                guard decoded.status == "ok" else {
                                    return handler.settings.queues.response.async {
                                        completionHandler(.failure(GenericError.unknown))
                                    }
                                }
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
        // prepare body.
        guard let url = try? Endpoints.Media.configureMedia.url() else { return completionHandler(.failure(GenericError.invalidUrl)) }
        let device = handler.settings.device
        let version = device.firmwareFingerprint.split(separator: "/")[2].split(separator: ":")[1]
        guard let user = storage.user,
            let androidVersion = try? Version(from: String(version)) else {
                return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        let configureDevice = ConfigureDevice.init(manufacturer: device.hardwareManufacturer,
                                                   model: device.hardwareModel,
                                                   androidVersion: androidVersion.number,
                                                   androidRelease: androidVersion.apiLevel)
        let configureEdits = ConfigureEdits.init(cropOriginalSize: [Int(photo.size.width),
                                                                    Int(photo.size.height)],
                                                 cropCenter: [0.0, -0.0],
                                                 cropZoom: 1)
        let configureExtras = ConfigureExtras.init(sourceWidth: Int(photo.size.width), sourceHeight: Int(photo.size.height))
        let configure = ConfigurePhotoModel.init(uuid: device.deviceGuid.uuidString,
                                                 uid: user.identity.primaryKey ?? -1,
                                                 csrfToken: storage.csrfToken,
                                                 mediaFolder: "Camera",
                                                 sourceType: "4",
                                                 caption: caption,
                                                 uploadId: uploadId,
                                                 device: configureDevice,
                                                 edits: configureEdits,
                                                 extras: configureExtras)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(configure), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes).toHexString()

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.decode(Upload.Response.Picture.self,
                            method: .post,
                            url: url,
                            body: .parameters(body),
                            completionHandler: completionHandler)
        } catch { completionHandler(.failure(error)) }
    }

    // swiftlint:disable line_length
    // No way this could work. I've commented it out cause it wasn't implemented right.
    /*fileprivate func getUploadIdsForPhotoAlbum(uploadIds: [String], photos: [InstaPhoto], completion: @escaping ([String]) -> ()) {
     if photos.count == 0 {
     completion(uploadIds)
     } else {
     var _uploadIds = uploadIds
     var _photos = photos
     let _currentPhoto = _photos.removeFirst()

     let _device = HandlerSettings.shared.device!
     let _user = HandlerSettings.shared.user!
     let _request = HandlerSettings.shared.request!

     let uploadId = _request.generateUploadId()
     var content = Data()
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Type: text/plain; charset=utf-8\n")
     content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
     content.append(string: "\(uploadId)\n")
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Type: text/plain; charset=utf-8\n")
     content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
     content.append(string: "\(_device.deviceGuid.uuidString)\n")
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Type: text/plain; charset=utf-8\n")
     content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
     content.append(string: "\(_user.csrfToken)\n")
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Type: text/plain; charset=utf-8\n")
     content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
     content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Type: text/plain; charset=utf-8\n")
     content.append(string: "Content-Disposition: form-data; name=\"is_sidecar\"\n\n")
     content.append(string: "1\n")
     content.append(string: "--\(uploadId)\n")
     content.append(string: "Content-Transfer-Encoding: binary\n")
     content.append(string: "Content-Type: application/octet-stream\n")
     content.append(string: "Content-Disposition: form-data; name=photo; filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n")

     let imageData = _currentPhoto.image.jpegData(compressionQuality: 1)

     content.append(imageData!)
     content.append(string: "\n--\(uploadId)--\n\n")

     let header = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
     guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
     httpHelper.sendAsync(method: .post, url: try URLs.getUploadPhotoUrl(), body: [:], header: header, data: content) { [weak self] (data, response, error) in
     if error != nil {
     completion(_uploadIds)
     } else {
     if let data = data {
     let decoder = JSONDecoder()
     decoder.keyDecodingStrategy = .convertFromSnakeCase
     do {
     let res = try decoder.decode(UploadPhotoResponse.self, from: data)
     if res.status! == "ok" {
     _uploadIds.append(res.uploadId!)
     self!.getUploadIdsForPhotoAlbum(uploadIds: _uploadIds, photos: _photos, completion: { (ids) in
     completion(ids)
     })
     } else {
     completion(_uploadIds)
     }
     } catch {
     completion(_uploadIds)
     }
     } else {
     completion(_uploadIds)
     }
     }
     }

     }
     }

     fileprivate func configureMediaAlbum(uploadIds: [String], caption: String, completion: @escaping (UploadPhotoAlbumResponse?, Error?) -> ()) {
     let url = try URLs.getConfigureMediaAlbumUrl()
     let _device = HandlerSettings.shared.device!
     let _user = HandlerSettings.shared.user!
     let _request = HandlerSettings.shared.request!


     let clientSidecarId = _request.generateUploadId()

     var childrens: [ConfigureChildren] = []
     for id in uploadIds {
     childrens.append(ConfigureChildren.init(scene_capture_type: "standard", mas_opt_in: "NOT_PROMPTED", camera_position: "unknown", allow_multi_configures: false, geotag_enabled: false, disable_comments: false, source_type: 0, upload_id: id))
     }

     let content = ConfigurePhotoAlbumModel.init(_uuid: _device.deviceGuid.uuidString, _uid: _user.loggedInUser.pk!, _csrftoken: _user.csrfToken, caption: caption, client_sidecar_id: clientSidecarId, geotag_enabled: false, disable_comments: false, children_metadata: childrens)

     let encoder = JSONEncoder()
     let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
     let hash = payload.hmac(algorithm: .SHA256, key: Headers.igSignatureValue)
     // Creating Post Request Body
     let signature = "\(hash).\(payload)"
     let body: [String: Any] = [
     Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
     Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
     ]
     guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
     httpHelper.sendAsync(method: .post, url: url, body: body, header: [:]) { (data, response, error) in
     if let error = error {
     completion(nil, error)
     } else {
     if let data = data {
     let decoder = JSONDecoder()
     decoder.keyDecodingStrategy = .convertFromSnakeCase
     do {
     let res = try decoder.decode(UploadPhotoAlbumResponse.self, from: data)
     completion(res, nil)
     } catch {
     completion(nil, error)
     }
     }
     }
     }
     }*/
    // swiftlint:enable line_length

    // Make sure file is valid (correct format, codecs, width, height and aspect ratio)
    // also its important to provide fileName.extenstion in InstaVideo
    // to convert video to data you need to pass file's URL to Data.init(contentsOf: URL)
    public func upload(video: Upload.Video,
                       thumbnail: Upload.Picture,
                       caption: String,
                       completionHandler: @escaping (Result<Media, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)
        // prepare content.
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"media_type\"\r\n\r\n")
        content.append(string: "2\r\n")
        content.append(string: "--\(uploadId)\r\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\r\n\r\n")
        content.append(string: "\(uploadId)\r\n")
        content.append(string: "--\(uploadId)\r\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\r\n\r\n")
        content.append(string: "\(handler!.settings.device.deviceGuid.uuidString)\r\n")
        content.append(string: "--\(uploadId)\r\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n")
        content.append(string: "\(storage.csrfToken)\n")
        content.append(string: "--\(uploadId)\r\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\r\n\r\n")
        content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\r\n")
        content.append(string: "--\(uploadId)--\r\n\r\n")

        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.decode(Upload.Response.Video.self,
                        method: .post,
                        url: Result { try Endpoints.Upload.uploadVideo.url() },
                        body: .data(content),
                        headers: headers,
                        deliverOnResponseQueue: false) { [weak self] in
                            guard let me = self, let handler = me.handler else {
                                return completionHandler(.failure(GenericError.weakObjectReleased))
                            }
                            switch $0 {
                            case .failure(let error):
                                handler.settings.queues.response.async {
                                    completionHandler(.failure(error))
                                }
                            case .success(let decoded):
                                guard decoded.status == "ok",
                                    let url = decoded.urls.first,
                                    let job = url.job,
                                    let path = url.url?.removingPercentEncoding,
                                    let uploadUrl = URL(string: path) else {
                                        return handler.settings.queues.response.async {
                                            completionHandler(.failure(GenericError.unknown))
                                        }
                                }

                                let headers = ["Host": "upload.instagram.com",
                                               "Cookie2": "$Version=1",
                                               "Session-ID": uploadId,
                                               "job": job,
                                               "Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
                                var videoContent = Data()
                                videoContent.append(string: "--\(uploadId)\r\n")
                                videoContent.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
                                videoContent.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n")
                                videoContent.append(string: "\(storage.csrfToken)\n")
                                videoContent.append(string: "--\(uploadId)\r\n")
                                videoContent.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
                                videoContent.append(string: "Content-Disposition: form-data; name=\"image_compression\"\r\n\r\n")
                                videoContent.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\r\n")
                                videoContent.append(string: "--\(uploadId)\r\n")
                                videoContent.append(string: "Content-Transfer-Encoding: binary\r\n")
                                videoContent.append(string: "Content-Type: application/octet-stream\r\n")
                                videoContent.append(string: "Content-Disposition: attachment; filename=\"\(video.file)\"\r\n\r\n")
                                videoContent.append(video.data)
                                videoContent.append(string: "\r\n--\(uploadId)--\r\n\r\n")

                                me.requests.fetch(method: .post,
                                                  url: uploadUrl,
                                                  body: .data(videoContent),
                                                  headers: headers) {
                                                    switch $0 {
                                                    case .failure(let error):
                                                        handler.settings.queues.response.async {
                                                            completionHandler(.failure(error))
                                                        }
                                                    case .success(let data, let response):
                                                        guard data != nil, response?.statusCode == 200 else {
                                                            return handler.settings.queues.response.async {
                                                                completionHandler(.failure(GenericError.unknown))
                                                            }
                                                        }
                                                        me.upload(thumbnail: thumbnail, with: uploadId) {
                                                            switch $0 {
                                                            case .failure(let error):
                                                                handler.settings.queues.response.async {
                                                                    completionHandler(.failure(error))
                                                                }
                                                            case .success(let hasBeenUploaded):
                                                                guard hasBeenUploaded else {
                                                                    return handler.settings.queues.response.async {
                                                                        completionHandler(.failure(GenericError.unknown))
                                                                    }
                                                                }
                                                                // configure video.
                                                                me.configure(video: video,
                                                                             with: uploadId,
                                                                             caption: caption,
                                                                             completionHandler: completionHandler)
                                                            }
                                                        }
                                                    }
                                }
                            }
        }
    }

    func upload(thumbnail: Upload.Picture,
                with uploadId: String,
                completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        guard let url = try? Endpoints.Upload.uploadPhoto.url() else {
            return completionHandler(.failure(GenericError.invalidUrl))
        }
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
        content.append(string: "\(uploadId)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
        content.append(string: "\(handler!.settings.device.deviceGuid.uuidString)\r\n")
        content.append(string: "--\(uploadId)\r\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\r\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n")
        content.append(string: "\(storage.csrfToken)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
        content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Transfer-Encoding: binary\n")
        content.append(string: "Content-Type: application/octet-stream\n")
        content.append(string: ["Content-Disposition: form-data; name=photo;",
                                "filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n"]
            .joined(separator: " "))

        #if os(macOS)
        let imageData = thumbnail.image.tiffRepresentation
        #else
        let imageData = thumbnail.image.jpegData(compressionQuality: 1)
        #endif
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.fetch(method: .post,
                       url: url,
                       body: .data(content),
                       headers: headers) {
                        switch $0 {
                        case .failure(let error): completionHandler(.failure(error))
                        case .success(let data, let response) where data != nil && response?.statusCode == 200:
                            completionHandler(.success(true))
                        default:
                            completionHandler(.success(false))
                        }
        }
    }

    func configure(video: Upload.Video,
                   with uploadId: String,
                   caption: String,
                   completionHandler: @escaping (Result<Media, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        guard let url = try? Endpoints.Media.configureMedia.url() else {
            return completionHandler(.failure(GenericError.invalidUrl))
        }
        let headers = [Headers.contentTypeKey: Headers.contentTypeApplicationFormValue,
                       "Host": "i.instagram.com"]

        let extra = ConfigureExtras.init(sourceWidth: 0, sourceHeight: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM'T'H:mm:ss-0SSS"
        let clips = ClipsModel.init(length: 10,
                                    creationDate: formatter.string(from: Date()),
                                    sourceType: "3",
                                    cameraPosition: "back")
        let content = ConfigureVideoModel(caption: caption,
                                          uploadId: uploadId,
                                          sourceType: "3",
                                          cameraPosition: "unknown",
                                          extra: extra,
                                          clips: [clips],
                                          posterFrameIndex: 0,
                                          audioMuted: video.isAudioMuted,
                                          filterType: "0",
                                          videoResult: "deprecated",
                                          csrfToken: "",
                                          uuid: handler!.settings.device.deviceGuid.uuidString,
                                          uid: storage.dsUserId)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(content), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes).toHexString()

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.decode(Media.self,
                            method: .post,
                            url: url,
                            body: .parameters(body),
                            headers: headers,
                            completionHandler: completionHandler)
        } catch { completionHandler(.failure(error)) }
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

        requests.parse(Bool.self,
                       method: .post,
                       url: Result { try Endpoints.Media.deleteMedia.resolving(mediaId, type.rawValue).url() },
                       body: .parameters(body),
                       processingHandler: { $0.didDelete.bool ?? false },
                       completionHandler: completionHandler)
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

        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "caption_text": caption,
                       "usertags": tagPayload]
        guard let payload = try? String(data: encoder.encode(content), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes).toHexString()

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.decode(Media.self,
                            method: .post,
                            url: Result { try Endpoints.Media.editMedia.resolving(mediaId).url() },
                            body: .parameters(body),
                            completionHandler: completionHandler)
        } catch { completionHandler(.failure(error)) }
    }

    /// Get media likers.
    public func likers(ofMedia mediaId: String,
                       with paginationParameters: PaginationParameters,
                       updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                       completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.parse(User.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try Endpoints.Media.likers.resolving(mediaId).url(with: ["max_id": $0.nextMaxId]) },
                    processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Get media permalink.
    public func permalink(ofMedia mediaId: String, completionHandler: @escaping (Result<String?, Error>) -> Void) {
        requests.parse(String?.self,
                       method: .get,
                       url: Result { try Endpoints.Media.permalink.resolving(mediaId).url() },
                       processingHandler: { $0.permalink.string },
                       completionHandler: completionHandler)
    }
}
