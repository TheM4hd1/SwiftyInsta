//
//  StoryHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/26/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol StoryHandlerProtocol {
    func getStoryFeed(completion: @escaping (Result<StoryFeedModel>) -> ()) throws
    func getUserStory(userId: Int, completion: @escaping (Result<TrayModel>) -> ()) throws
    func getUserStoryReelFeed(userId: Int, completion: @escaping (Result<StoryReelFeedModel>) -> ()) throws
    func uploadStoryPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws
    func getStoryViewers(storyPk: String?, completion: @escaping (Result<StoryViewers>) -> ()) throws
}

class StoryHandler: StoryHandlerProtocol {
    static let shared = StoryHandler()
    
    private init() {
        
    }
    
    func getStoryFeed(completion: @escaping (Result<StoryFeedModel>) -> ()) throws {
        HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: try URLs.getStoryFeedUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(StoryFeedModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    let error = CustomErrors.unExpected("The data couldn’t be read because it is missing error when decoding JSON.")
                    completion(Return.fail(error: error, response: .ok, value: nil))
                }
            }
        }
    }
    
    func getUserStory(userId: Int, completion: @escaping (Result<TrayModel>) -> ()) throws {
        HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: try URLs.getUserStoryUrl(userId: userId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(TrayModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    let error = CustomErrors.unExpected("The data couldn’t be read because it is missing error when decoding JSON.")
                    completion(Return.fail(error: error, response: .ok, value: nil))
                }
            }
        }
    }
    
    func getUserStoryReelFeed(userId: Int, completion: @escaping (Result<StoryReelFeedModel>) -> ()) throws {
        HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: try URLs.getUserStoryFeed(userId: userId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(StoryReelFeedModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    let error = CustomErrors.unExpected("The data couldn’t be read because it is missing error when decoding JSON.")
                    completion(Return.fail(error: error, response: .ok, value: nil))
                }
            }
        }
    }
    
    func uploadStoryPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        let uploadId = HandlerSettings.shared.request!.generateUploadId()
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
        content.append(string: "\(uploadId)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
        content.append(string: "\(HandlerSettings.shared.device!.deviceGuid.uuidString)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
        content.append(string: "\(HandlerSettings.shared.user!.csrfToken)\n")
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
        
        let header = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getUploadPhotoUrl(), body: [:], header: header, data: content) { [weak self] (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let uploadRes = try decoder.decode(UploadPhotoResponse.self, from: data)
                        if uploadRes.status! == "ok" {
                            self!.configureStoryPhoto(uploadId: uploadRes.uploadId!, caption: photo.caption, completion: { (result) in
                                completion(Return.success(value: result))
                            })
                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    fileprivate func configureStoryPhoto(uploadId: String, caption: String, completion: @escaping (UploadPhotoResponse?) -> ()) {
        let data = ConfigureStoryUploadModel.init(_uuid: HandlerSettings.shared.device!.deviceGuid.uuidString, _uid: String(HandlerSettings.shared.user!.loggedInUser.pk!), _csrftoken: HandlerSettings.shared.user!.csrfToken, source_type: "1", caption: caption, upload_id: uploadId, disable_comments: false, configure_mode: 1, campera_position: "unknown")
        
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(data), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        // Creating Post Request Body
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try! URLs.getConfigureStoryUrl(), body: body, header: [:]) { (data, response, error) in
            if error != nil {
                completion(nil)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(UploadPhotoResponse.self, from: data)
                        completion(value)
                    } catch {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getStoryViewers(storyPk: String?, completion: @escaping (Result<StoryViewers>) -> ()) throws {
        HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: try URLs.getStoryViewersUrl(pk: storyPk!), body: [:], header: [:]) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
                completion(Return.fail(error: err, response: .fail, value: nil))
            } else {
                if let data = data {
                    if response?.statusCode == 200 {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let value = try decoder.decode(StoryViewers.self, from: data)
                            completion(Return.success(value: value))
                        } catch {
                            completion(Return.fail(error: error, response: .fail, value: nil))
                        }
                    } else {
                        let err = CustomErrors.unExpected("status code: \(response?.statusCode ?? -1)")
                        completion(Return.fail(error: err, response: .fail, value: nil))
                    }
                }
            }
        }
    }
}
