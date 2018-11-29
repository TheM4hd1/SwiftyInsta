//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol APIHandlerProtocol:
    UserHandlerProtocol,
    ProfileHandlerProtocol,
    FeedHandlerProtocol,
    MediaHandlerProtocol,
    MessageHandlerProtocol,
    CommentHandlerProtocol,
    StoryHandlerProtocol {
}

class APIHandler: APIHandlerProtocol {
    
    init(request: RequestMessageModel, user: SessionStorage, device: AndroidDeviceModel, delay: DelayModel, config: URLSessionConfiguration) {
        // TODO: - Update Handler Settings
        HandlerSettings.shared.delay = delay
        HandlerSettings.shared.user = user
        HandlerSettings.shared.device = device
        HandlerSettings.shared.request = request
        HandlerSettings.shared.httpHelper = HttpHelper(config: config)
        HandlerSettings.shared.queue = DispatchQueue.global(qos: .utility)
        HandlerSettings.shared.isUserAuthenticated = false
    }
    
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) throws {
        // validating before login.
        try validateUser()
        try validateRequestMessage()
        
        try UserHandler.shared.login { (result) in
            completion(result)
        }
    }
    
    func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
        try UserHandler.shared.createAccount(account: account) { (result) in
            completion(result)
        }
    }
    
    func logout(completion: @escaping (Result<Bool>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.logout { (result) in
            completion(result)
        }
    }
    
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUser(username: username) { (result) in
            completion(result)
        }
    }
    
    func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUser(id: id) { (result) in
            completion(result)
        }
    }
    
    func getUserFollowing(username: String, paginationParameter: PaginationParameters, searchQuery: String = "", completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserFollowing(username: username, paginationParameter: paginationParameter, searchQuery: searchQuery) { (result) in
            completion(result)
        }
    }
    
    func getUserFollowers(username: String, paginationParameter: PaginationParameters, searchQuery: String, completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserFollowers(username: username, paginationParameter: paginationParameter, searchQuery: searchQuery) { (result) in
            completion(result)
        }
    }
    
    func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getCurrentUser { (result) in
            completion(result)
        }
    }
    
    func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getExploreFeeds(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getUserTimeLine(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getUserMedia(for username: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.getUserMedia(for: username, paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getMediaInfo(mediaId: String, completion: @escaping (Result<MediaModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.getMediaInfo(mediaId: mediaId) { (result) in
            completion(result)
        }
    }
    
    func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getTagFeed(tagName: tagName, paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getRecentActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getRecentActivities(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getRecentFollowingActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentFollowingsActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getRecentFollowingActivities(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    func getDirectInbox(completion: @escaping (Result<DirectInboxModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getDirectInbox { (result) in
            completion(result)
        }
    }
    
    func sendDirect(to userIds: String, in threadIds: String, with text: String, completion: @escaping (Result<DirectSendMessageResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.sendDirect(to: userIds, in: threadIds, with: text) { (result) in
            completion(result)
        }
    }
    
    func getDirectThreadById(threadId: String, completion: @escaping (Result<ThreadModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getDirectThreadById(threadId: threadId) { (result) in
            completion(result)
        }
    }
    
    func getRecentDirectRecipients(completion: @escaping (Result<RecentRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getRecentDirectRecipients { (result) in
            completion(result)
        }
    }
    
    func getRankedDirectRecipients(completion: @escaping (Result<RankedRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getRankedDirectRecipients { (result) in
            completion(result)
        }
    }
    
    func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setAccountPublic { (result) in
            completion(result)
        }
    }
    
    func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setAccountPrivate { (result) in
            completion(result)
        }
    }
    
    func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setNewPassword(oldPassword: oldPassword, newPassword: newPassword) { (result) in
            completion(result)
        }
    }
    
    func likeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.likeMedia(mediaId: mediaId, completion: { (result) in
            completion(result)
        })
    }
    
    func unLikeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.unLikeMedia(mediaId: mediaId, completion: { (result) in
            completion(result)
        })
    }
    
    func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try CommentHandler.shared.getMediaComments(mediaId: mediaId, paginationParameter: paginationParameter, completion: { (result) in
            completion(result)
        })
    }
    
    func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.followUser(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.unFollowUser(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getFriendshipStatus(of: userId) { (result) in
            completion(result)
        }
    }
    
    func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.block(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.unBlock(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func getUserTags(userId: Int, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserTags(userId: userId, paginationParameter: paginationParameter, completion: { (result) in
            completion(result)
        })
    }
    
    func uploadPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.uploadPhoto(photo: photo, completion: { (result) in
            completion(result)
        })
    }
    
    func uploadPhotoAlbum(photos: [InstaPhoto], caption: String, completion: @escaping (Result<UploadPhotoAlbumResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.uploadPhotoAlbum(photos: photos, caption: caption, completion: { (result) in
            completion(result)
        })
    }
    
    func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try CommentHandler.shared.addComment(mediaId: mediaId, comment: text, completion: { (result) in
            completion(result)
        })
    }
    
    func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try CommentHandler.shared.deleteComment(mediaId: mediaId, commentPk: commentPk, completion: { (result) in
            completion(result)
        })
    }
    
//    func uploadVideo(video: InstaVideo?, imageTumbnail: InstaPhoto?, caption: String?, completion: @escaping (Bool) -> ()) throws {
//        // validate before request.
//        try validateUser()
//        try validateLoggedIn()
//
//        try MediaHandler.shared.uploadVideo(video: nil, imageTumbnail: nil, caption: nil, completion: { (result) in
//            completion(result)
//        })
//    }
    
    func deleteMedia(mediaId: String, mediaType: MediaTypes, completion: @escaping (Result<DeleteMediaResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()

        try MediaHandler.shared.deleteMedia(mediaId: mediaId, mediaType: mediaType, completion: { (result) in
            completion(result)
        })
    }
    
    func getStoryFeed(completion: @escaping (Result<StoryFeedModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getStoryFeed(completion: { (result) in
            completion(result)
        })
    }
    
    func getUserStory(userId: Int, completion: @escaping (Result<TrayModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getUserStory(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func getUserStoryReelFeed(userId: Int, completion: @escaping (Result<StoryReelFeedModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getUserStoryReelFeed(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    func uploadStoryPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.uploadStoryPhoto(photo: photo, completion: { (result) in
            completion(result)
        })
    }
    
    func editProfile(name: String, biography: String, url: String, email: String, phone: String, gender: GenderTypes, newUsername: String, completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.editProfile(name: name, biography: biography, url: url, email: email, phone: phone, gender: gender, newUsername: newUsername, completion: { (result) in
            completion(result)
        })
    }
    
    func editBiography(text bio: String, completion: @escaping (Result<Bool>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.editBiography(text: bio, completion: { (result) in
            completion(result)
        })
    }
    
    func removeProfilePicture(completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.removeProfilePicture(completion: { (result) in
            completion(result)
        })
    }
    
    fileprivate func validateUser() throws {
        if HandlerSettings.shared.user!.username.isEmpty || HandlerSettings.shared.user!.password.isEmpty {
            throw CustomErrors.runTimeError("username and password must be specified.")
        }
    }
    
    fileprivate func validateLoggedIn() throws {
        if !HandlerSettings.shared.isUserAuthenticated! {
            throw CustomErrors.runTimeError("user must be authenticated.")
        }
    }
    
    fileprivate func validateRequestMessage() throws {
        if HandlerSettings.shared.request!.isEmpty() {
            throw CustomErrors.runTimeError("empty request message.")
        }
    }
}

