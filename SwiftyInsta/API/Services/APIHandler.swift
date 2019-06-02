//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol APIHandlerProtocol:
    UserHandlerProtocol,
    ProfileHandlerProtocol,
    FeedHandlerProtocol,
    MediaHandlerProtocol,
    MessageHandlerProtocol,
    CommentHandlerProtocol,
    StoryHandlerProtocol {
}

public class APIHandler: APIHandlerProtocol {
    
    public init() {
        
    }
    
    public init(request: RequestMessageModel, user: SessionStorage, device: AndroidDeviceModel, delay: DelayModel, urlSession: URLSession) {
        // TODO: - Update Handler Settings
        HandlerSettings.shared.delay = delay
        HandlerSettings.shared.user = user
        HandlerSettings.shared.device = device
        HandlerSettings.shared.request = request
        HandlerSettings.shared.httpHelper = HttpHelper(urlSession: urlSession)
        HandlerSettings.shared.queue = DispatchQueue.global(qos: .utility)
        HandlerSettings.shared.isUserAuthenticated = false
    }
    
    public func login(cache: SessionCache, completion: @escaping (Result<LoginResultModel>) -> ()) throws {
        try UserHandler.shared.login(cache: cache, completion: { (result) in
            completion(result)
        })
    }
    
    public func login(completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        // validating before login.
        try validateUser()
        try validateRequestMessage()
        
        try UserHandler.shared.login { (result, cache) in
            completion(result, cache)
        }
    }
    
    public func twoFactorLogin(verificationCode: String, useBackupCode: Bool, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        try UserHandler.shared.twoFactorLogin(verificationCode: verificationCode, useBackupCode: useBackupCode, completion: { (result, cache) in
            completion(result, cache)
        })
    }
    
    /// Resend TwoFactor Sms
    public func sendTwoFactorLoginSms(completion: @escaping (Result<Bool>) -> ()) throws {
        try UserHandler.shared.sendTwoFactorLoginSms(completion: { (result) in
            completion(result)
        })
    }
    
    /// to login with challenge, you need to go through 3 steps.
    /// 1. ```challengeLogin(_)```, if you get ```verifyRequired``` result, run step 2
    /// 2. ```verifyMethod(_,_)```, if you get ```codeSent``` result, run step 3
    /// 3. ```sendVerifyCode(_,_)```, if you get ```success``` result, you're logged-in now
    public func challengeLogin(completion: @escaping (Result<ResponseTypes>) -> ()) throws {
        if HandlerSettings.shared.challenge == nil {
            let error = CustomErrors.runTimeError("challenge require info is empty.\r\ntry to call login function first.")
            completion(Return.fail(error: error, response: .challengeRequired, value: nil))
        } else {
            try UserHandler.shared.challengeLogin(completion: { (result) in
                completion(result)
            })
        }
    }
    
    public func verifyMethod(of type: VerifyTypes, completion: @escaping (Result<VerifyResponse>) -> ()) throws {
        if HandlerSettings.shared.challenge == nil {
            let error = CustomErrors.runTimeError("challenge require info is empty.\r\ntry to call login function first.")
            completion(Return.fail(error: error, response: .challengeRequired, value: nil))
        } else {
            try UserHandler.shared.verifyMethod(of: type, completion: { (result) in
                completion(result)
            })
        }
    }
    
    public func sendVerifyCode(securityCode: String, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        if HandlerSettings.shared.challenge == nil {
            let error = CustomErrors.runTimeError("challenge require info is empty.\r\ntry to call login function first.")
            completion(Return.fail(error: error, response: .challengeRequired, value: .challengeRequired), nil)
        } else {
            try UserHandler.shared.sendVerifyCode(securityCode: securityCode, completion: { (result, cache) in
                completion(result, cache)
            })
        }
    }
    
    public func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
        try UserHandler.shared.createAccount(account: account) { (result) in
            completion(result)
        }
    }
    
    public func logout(completion: @escaping (Result<Bool>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.logout { (result) in
            completion(result)
        }
    }
    
    public func searchUser(username: String, completion: @escaping (Result<[UserModel]>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.searchUser(username: username, completion: { (result) in
            completion(result)
        })
    }
    
    public func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUser(username: username) { (result) in
            completion(result)
        }
    }
    
    public func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUser(id: id) { (result) in
            completion(result)
        }
    }
    
    public func getUserFollowing(username: String, paginationParameter: PaginationParameters, searchQuery: String = "", completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserFollowing(username: username, paginationParameter: paginationParameter, searchQuery: searchQuery) { (result) in
            completion(result)
        }
    }
    
    public func getUserFollowers(username: String, paginationParameter: PaginationParameters, searchQuery: String, completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserFollowers(username: username, paginationParameter: paginationParameter, searchQuery: searchQuery) { (result) in
            completion(result)
        }
    }
    
    public func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getCurrentUser { (result) in
            completion(result)
        }
    }
    
    public func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getExploreFeeds(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getUserTimeLine(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getUserMedia(for username: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.getUserMedia(for: username, paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getMediaInfo(mediaId: String, completion: @escaping (Result<MediaModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.getMediaInfo(mediaId: mediaId) { (result) in
            completion(result)
        }
    }
    
    public func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try FeedHandler.shared.getTagFeed(tagName: tagName, paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getRecentActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getRecentActivities(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getRecentFollowingActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentFollowingsActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getRecentFollowingActivities(paginationParameter: paginationParameter) { (result) in
            completion(result)
        }
    }
    
    public func getDirectInbox(completion: @escaping (Result<DirectInboxModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getDirectInbox { (result) in
            completion(result)
        }
    }
    
    public func sendDirect(to userIds: String, in threadIds: String, with text: String, completion: @escaping (Result<DirectSendMessageResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.sendDirect(to: userIds, in: threadIds, with: text) { (result) in
            completion(result)
        }
    }
    
    public func getDirectThreadById(threadId: String, completion: @escaping (Result<ThreadModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getDirectThreadById(threadId: threadId) { (result) in
            completion(result)
        }
    }
    
    public func getRecentDirectRecipients(completion: @escaping (Result<RecentRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getRecentDirectRecipients { (result) in
            completion(result)
        }
    }
    
    public func getRankedDirectRecipients(completion: @escaping (Result<RankedRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MessageHandler.shared.getRankedDirectRecipients { (result) in
            completion(result)
        }
    }
    
    public func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setAccountPublic { (result) in
            completion(result)
        }
    }
    
    public func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setAccountPrivate { (result) in
            completion(result)
        }
    }
    
    public func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.setNewPassword(oldPassword: oldPassword, newPassword: newPassword) { (result) in
            completion(result)
        }
    }
    
    public func likeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.likeMedia(mediaId: mediaId, completion: { (result) in
            completion(result)
        })
    }
    
    public func unLikeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.unLikeMedia(mediaId: mediaId, completion: { (result) in
            completion(result)
        })
    }
    
    public func getMediaLikers(mediaId: String, completion: @escaping (Result<MediaLikersModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.getMediaLikers(mediaId: mediaId, completion: { (result) in
            completion(result)
        })
    }
    
    public func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try CommentHandler.shared.getMediaComments(mediaId: mediaId, paginationParameter: paginationParameter, completion: { (result) in
            completion(result)
        })
    }
    
    public func removeFollower(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.removeFollower(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func approveFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.approveFriendship(userId: userId, completion: { (result) in
            completion(result)
        })

    }
    
    public func rejectFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.rejectFriendship(userId: userId, completion: { (result) in
            completion(result)
        })

    }
    
    public func pendingFriendships(completion: @escaping (Result<PendingFriendshipsModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.pendingFriendships(completion: { (result) in
            completion(result)
        })
    }
    
    public func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.followUser(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.unFollowUser(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getFriendshipStatus(of: userId) { (result) in
            completion(result)
        }
    }
    
    public func getFriendshipStatuses(of userIds: [Int], completion: @escaping (Result<FriendshipStatusesModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getFriendshipStatuses(of: userIds) { (result) in
            completion(result)
        }
        
    }
    
    public func getBlockedList(completion: @escaping (Result<BlockedUsersModel>) -> ()) throws {
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getBlockedList(completion: { (result) in
            completion(result)
        })
    }
    
    public func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.block(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.unBlock(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func getUserTags(userId: Int, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try UserHandler.shared.getUserTags(userId: userId, paginationParameter: paginationParameter, completion: { (result) in
            completion(result)
        })
    }
    
    public func uploadPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.uploadPhoto(photo: photo, completion: { (result) in
            completion(result)
        })
    }
    
    public func uploadPhotoAlbum(photos: [InstaPhoto], caption: String, completion: @escaping (Result<UploadPhotoAlbumResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.uploadPhotoAlbum(photos: photos, caption: caption, completion: { (result) in
            completion(result)
        })
    }
    
    public func uploadVideo(video: InstaVideo, imageThumbnail: InstaPhoto, caption: String, completion: @escaping (Result<MediaModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.uploadVideo(video: video, imageThumbnail: imageThumbnail, caption: caption, completion: { (result) in
            completion(result)
        })
    }
    
    public func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try CommentHandler.shared.addComment(mediaId: mediaId, comment: text, completion: { (result) in
            completion(result)
        })
    }
    
    public func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws {
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
    
    public func deleteMedia(mediaId: String, mediaType: MediaTypes, completion: @escaping (Result<DeleteMediaResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()

        try MediaHandler.shared.deleteMedia(mediaId: mediaId, mediaType: mediaType, completion: { (result) in
            completion(result)
        })
    }
    
    public func getStoryFeed(completion: @escaping (Result<StoryFeedModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getStoryFeed(completion: { (result) in
            completion(result)
        })
    }
    
    public func getUserStory(userId: Int, completion: @escaping (Result<TrayModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getUserStory(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func getUserStoryReelFeed(userId: Int, completion: @escaping (Result<StoryReelFeedModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getUserStoryReelFeed(userId: userId, completion: { (result) in
            completion(result)
        })
    }
    
    public func uploadStoryPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.uploadStoryPhoto(photo: photo, completion: { (result) in
            completion(result)
        })
    }
    
    public func getStoryViewers(storyPk: String?, completion: @escaping (Result<StoryViewers>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try StoryHandler.shared.getStoryViewers(storyPk: storyPk, completion: { (result) in
            completion(result)
        })
    }
    
    public func editProfile(name: String, biography: String, url: String, email: String, phone: String, gender: GenderTypes, newUsername: String, completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.editProfile(name: name, biography: biography, url: url, email: email, phone: phone, gender: gender, newUsername: newUsername, completion: { (result) in
            completion(result)
        })
    }
    
    public func editBiography(text bio: String, completion: @escaping (Result<Bool>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.editBiography(text: bio, completion: { (result) in
            completion(result)
        })
    }
    
    public func removeProfilePicture(completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.removeProfilePicture(completion: { (result) in
            completion(result)
        })
    }
    
    public func uploadProfilePicture(photo: InstaPhoto, completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try ProfileHandler.shared.uploadProfilePicture(photo: photo, completion: { (result) in
            completion(result)
        })
    }
    
    public func editMedia(mediaId: String, caption: String, tags: UserTags, completion: @escaping (Result<MediaModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try MediaHandler.shared.editMedia(mediaId: mediaId, caption: caption, tags: tags, completion: { (result) in
            completion(result)
        })
    }
    
    public func recoverAccountBy(username: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws {
        try UserHandler.shared.recoverAccountBy(username: username, completion: { (result) in
            completion(result)
        })
    }
    
    public func recoverAccountBy(email: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws {
        try UserHandler.shared.recoverAccountBy(email: email, completion: { (result) in
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

