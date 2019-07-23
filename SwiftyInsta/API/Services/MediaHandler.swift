//
//  MediaHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class MediaHandler: Handler {
    /// Get user media.
    public func by(user: UserReference,
                   with paginationParameters: PaginationParameters,
                   updateHandler: PaginationUpdateHandler<UserFeedModel>?,
                   completionHandler: @escaping PaginationCompletionHandler<UserFeedModel>) {
        switch user {
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.by(user: .pk(user!.pk!),
                               with: paginationParameters,
                               updateHandler: updateHandler,
                               completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")), paginationParameters)
                }
            }
        case .pk(let pk):
            // load media directly.
            pages.fetch(UserFeedModel.self,
                        with: paginationParameters,
                        at: { try URLs.getUserFeedUrl(userPk: pk, maxId: $0.nextMaxId ?? "") },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }
    
    /// Get media info.
    public func info(for mediaId: String, completionHandler: @escaping (Result<MediaModel, Error>) -> Void) {
        requests.decodeAsync(MediaModel.self,
                             method: .get,
                             url: try! URLs.getMediaUrl(mediaId: mediaId),
                             completionHandler: completionHandler)
    }

    /// Like media.
    public func like(media mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]

        requests.decodeAsync(BaseStatusResponseModel.self,
                             method: .post,
                             url: try! URLs.getLikeMediaUrl(mediaId: mediaId),
                             body: .parameters(body),
                             completionHandler: { completionHandler($0.map { $0.isOk() }) })
    }

    /// Unlike media.
    public func unlike(media mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]

        requests.decodeAsync(BaseStatusResponseModel.self,
                             method: .post,
                             url: try! URLs.getUnLikeMediaUrl(mediaId: mediaId),
                             body: .parameters(body),
                             completionHandler: { completionHandler($0.map { $0.isOk() }) })
    }

    /// Upload photo.
    public func upload(photo: InstaPhoto, completionHandler: @escaping (Result<UploadPhotoResponse, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
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
        content.append(string: "Content-Disposition: form-data; name=photo; filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n")

        let imageData = photo.image.jpegData(compressionQuality: 1)
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.decodeAsync(UploadPhotoResponse.self,
                             method: .post,
                             url: try! URLs.getUploadPhotoUrl(),
                             body: .data(content),
                             headers: headers,
                             deliverOnResponseQueue: false) { [weak self] in
                                guard let me = self, let handler = me.handler else {
                                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                                }
                                switch $0 {
                                case .failure(let error):
                                    handler.settings.queues.response.async {
                                        completionHandler(.failure(error))
                                    }
                                case .success(let decoded):
                                    guard decoded.status == "ok" else {
                                        return handler.settings.queues.response.async {
                                            completionHandler(.failure(CustomErrors.noError))
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
    func configure(photo: InstaPhoto,
                   with uploadId: String,
                   caption: String,
                   completionHandler: @escaping (Result<UploadPhotoResponse, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        let url = try! URLs.getConfigureMediaUrl()
        let _device = handler!.settings.device
        let _user = storage.user!
        let version = _device.frimwareFingerprint.split(separator: "/")[2].split(separator: ":")[1]
        let androidVersion = AndroidVersion.fromString(versionString: String(version))!
        let configureDevice = ConfigureDevice.init(manufacturer: _device.hardwareManufacturer, model: _device.hardwareModel, android_version: androidVersion.versionNumber, android_release: androidVersion.apiLevel)
        let configureEdits = ConfigureEdits.init(crop_original_size: [photo.width, photo.height], crop_center: [0.0, -0.0], crop_zoom: 1)
        let configureExtras = ConfigureExtras.init(source_width: photo.width, source_height: photo.height)
        let configure = ConfigurePhotoModel.init(_uuid: _device.deviceGuid.uuidString,
                                                 _uid: _user.pk!,
                                                 _csrftoken: storage.csrfToken,
                                                 media_folder: "Camera",
                                                 source_type: "4",
                                                 caption: caption,
                                                 upload_id: uploadId,
                                                 device: configureDevice,
                                                 edits: configureEdits,
                                                 extras: configureExtras)
            
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(configure), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
            
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
            
        requests.decodeAsync(UploadPhotoResponse.self,
                             method: .post,
                             url: url,
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }

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
            httpHelper.sendAsync(method: .post, url: try! URLs.getUploadPhotoUrl(), body: [:], header: header, data: content) { [weak self] (data, response, error) in
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
        let url = try! URLs.getConfigureMediaAlbumUrl()
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
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        // Creating Post Request Body
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
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
    
    // Make sure file is valid (correct format, codecs, width, height and aspect ratio)
    // also its important to provide fileName.extenstion in InstaVideo
    // to convert video to data you need to pass file's URL to Data.init(contentsOf: URL)
    public func upload(video: InstaVideo,
                       thumbnail: InstaPhoto,
                       caption: String,
                       completionHandler: @escaping (Result<MediaModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
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

        requests.decodeAsync(UploadVideoResponse.self,
                             method: .post,
                             url: try! URLs.getUploadVideoUrl(),
                             body: .data(content),
                             headers: headers,
                             deliverOnResponseQueue: false) { [weak self] in
                                guard let me = self, let handler = me.handler else {
                                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                                }
                                switch $0 {
                                case .failure(let error):
                                    handler.settings.queues.response.async {
                                        completionHandler(.failure(error))
                                    }
                                case .success(let decoded):
                                    guard decoded.status == "ok",
                                        let url = decoded.videoUploadUrls?.first,
                                        let job = url.job,
                                        let path = url.url?.removingPercentEncoding,
                                        let uploadUrl = URL(string: path) else {
                                        return handler.settings.queues.response.async {
                                            completionHandler(.failure(CustomErrors.noError))
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
                                    videoContent.append(string: "Content-Disposition: attachment; filename=\"\(video.fileName)\"\r\n\r\n")
                                    videoContent.append(video.data)
                                    videoContent.append(string: "\r\n--\(uploadId)--\r\n\r\n")
                                        
                                    me.requests.sendAsync(method: .post,
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
                                                                    completionHandler(.failure(CustomErrors.noError))
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
                                                                            completionHandler(.failure(CustomErrors.noError))
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
        
    func upload(thumbnail: InstaPhoto,
                with uploadId: String,
                completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let url = try! URLs.getUploadPhotoUrl()
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
        content.append(string: "Content-Disposition: form-data; name=photo; filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n")
        
        let imageData = thumbnail.image.jpegData(compressionQuality: 1)
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
        
        requests.sendAsync(method: .post,
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

    func configure(video: InstaVideo,
                   with uploadId: String,
                   caption: String,
                   completionHandler: @escaping (Result<MediaModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let url = try! URLs.getConfigureMediaUrl()
        let headers = [Headers.HeaderContentTypeKey: Headers.HeaderContentTypeApplicationFormValue,
                      "Host": "i.instagram.com"]
        
        let extra = ConfigureExtras.init(source_width: 0, source_height: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM'T'H:mm:ss-0SSS"
        let clips = ClipsModel.init(length: 10,
                                    creationDate: formatter.string(from: Date()),
                                    sourceType: "3", cameraPosition: "back")
        let content = ConfigureVideoModel(caption: caption,
                                          uploadId: uploadId,
                                          sourceType: "3",
                                          cameraPosition: "unknown",
                                          extra: extra,
                                          clips: [clips],
                                          posterFrameIndex: 0,
                                          audioMuted: video.audioMuted,
                                          filterType: "0",
                                          videoResult: "deprecated",
                                          _csrftoken: "",
                                          _uuid: handler!.settings.device.deviceGuid.uuidString,
                                          _uid: storage.dsUserId)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)

        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        requests.decodeAsync(MediaModel.self,
                             method: .post,
                             url: url,
                             body: .parameters(body),
                             headers: headers,
                             completionHandler: completionHandler)
    }
    
    /// Delete media.
    public func delete(media mediaId: String,
                       with type: MediaTypes,
                       completionHandler: @escaping (Result<DeleteMediaResponse, Error>)-> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "media_id": mediaId]
        
        requests.decodeAsync(DeleteMediaResponse.self,
                             method: .post,
                             url: try! URLs.getDeleteMediaUrl(mediaId: mediaId, mediaType: type.rawValue),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }

    /// Edit media.
    public func edit(media mediaId: String,
                     caption: String,
                     tags: UserTags,
                     completionHandler: @escaping (Result<MediaModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let encoder = JSONEncoder()
        let tagPayload = try! encoder.encode(tags)

        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "caption_text": caption,
                       "usertags": String(data: tagPayload, encoding: .utf8)!]
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)

        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        requests.decodeAsync(MediaModel.self,
                             method: .post,
                             url: try! URLs.getEditMediaUrl(mediaId: mediaId),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }
    
    /// Get media likers.
    public func likers(ofMedia mediaId: String, completionHandler: @escaping (Result<MediaLikersModel, Error>) -> Void) {
        requests.decodeAsync(MediaLikersModel.self,
                             method: .get,
                             url: try! URLs.getMediaLikersUrl(mediaId: mediaId),
                             completionHandler: completionHandler)
    }
}
