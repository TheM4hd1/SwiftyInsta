//
//  SwiftyInstaTests.swift
//  SwiftyInstaTests
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import XCTest
@testable import SwiftyInsta

class SwiftyInstaTests: XCTestCase {
    
    private var logoutAfterTest = true
    
    func testCalculateSignatureHash() {
        let message =
        """
        {"phone_id":"28484284-e646-4a29-88fc-76c2666d5ab3","username":"testusernameinstaminer","guid":"7f585e77-becf-4137-bf1f-84ab72e35eb4","device_id":"android-271e73ff77f246e7","password":"testpasswordinstaminer","login_attempt_count":"0"}
        """
        XCTAssertEqual("ebde2e05c55f3d41d89201ad75669e493a27408f46ef7f2395bb357456d6db5b", message.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue))
    }
    
    func testMD5hash() {
        XCTAssertEqual("220cb46b456b848c19b2825db5bd3838", "SwiftyInsta".MD5)
    }
    
    // ----------------------------
    // MARK: - User Handler Methods
    
    func testRecoverAccount() {
        let exp = expectation(description: "testRecoverAccount() faild during timeout")
        let urlSession = URLSession(configuration: .default)
        let user = SessionStorage.create(username: "", password: "")
        let handler = try! APIBuilder().createBuilder().setHttpHandler(urlSession:
            urlSession).setRequestDelay(delay: .default).setUser(user: user).build()
        do {
            try handler.recoverAccountBy(email: "swiftyinsta", completion: { (result) in
                print(result)
                exp.fulfill()
            })
        } catch {
            print(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testLogin() {
        
        // Clearing saved cookies before login.
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
        
        let exp = expectation(description: "login() faild during timeout")
        let user = SessionStorage.create(username: "swiftyinsta", password: "***")
        let userAgent = CustomUserAgent(apiVersion: "79.0.0.0", osName: "iOS", osVersion: "12", osRelease: "1.4", dpi: "458", resolution: "2688x1242", company: "Apple", model: "iPhone11,2", modem: "intel", locale: "en_US", fbCode: "95414346")
        HttpSettings.shared.addValue(userAgent.toString(), forHTTPHeaderField: Headers.HeaderUserAgentKey)
        let urlSession = URLSession(configuration: .default)
        let handler = try! APIBuilder().createBuilder().setHttpHandler(urlSession: urlSession).setRequestDelay(delay: .default).setUser(user: user).build()
        var _error: Error?
        do {
            try handler.login { (result, cache) in
                if result.isSucceeded {
                    print("[+]: logged in")
                } else {
                    print("[-] Login failed: \(result.info.error)")
                    _error = result.info.error
                }
                exp.fulfill()
            }
        } catch let error as CustomErrors {
            print(error.localizedDescription)
            exp.fulfill()
        } catch {
            print(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else if _error != nil {
                switch _error! {
                case CustomErrors.challengeRequired:
                    self.testLoginWithChallenge(handler: handler)
                case CustomErrors.twoFactorAuthentication:
                    self.testLoginTwoFactor(handler: handler)
                default:
                    print("[-] unexcpected error.")
                }
            } else {
                // FIXME: after the test is completed, the logout is handled by this variable.
                self.logoutAfterTest = true
                
                // FIXME: 'test function' you want to run after login.
                self.testRemoveFollower(handler: handler)
            }
        }
    }
    
    func testLoginTwoFactor(handler: APIHandlerProtocol) {
        print("[+] testing twoFactor login...")

        let verCode = "269475"
        
        let exp = expectation(description: "testLoginTwoFactor() faild during timeout")

        do {
            try handler.twoFactorLogin(verificationCode: verCode, useBackupCode: false, completion: { (result, cache) in
                print(result)
                exp.fulfill()
            })
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
            
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testLoginCache(handler: APIHandlerProtocol, cache: SessionCache) {
        print("[+] testing login cache...")
        
        // Clearing saved cookies for test.
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
        
        let exp = expectation(description: "testLoginCache() faild during timeout")
        do {
            try handler.login(cache: cache, completion: { (result) in
                if result.isSucceeded {
                    print("[+] login cache test succeeded.")
                } else {
                    print("[-] login cache test failed.")
                }
                
                exp.fulfill()
            })
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testLoginWithChallenge(handler: APIHandlerProtocol) {
        print("[+] trying to loggin with challenge.")
        let exp = expectation(description: "login() faild during timeout")
        //var _cache: SessionCache?
        do {
            // to test run this test, you need to set breakpoints at line 91 after you got the codeSent result,
            // change the value of 'securityCode' variable to recieved security code and continue the test.
            try handler.challengeLogin(completion: { (result) in
                print(result.value!)
                try! handler.verifyMethod(of: .email, completion: { (result) in
                    print(result.value!)
                    // FIXME: - Challenge Code
                    let securityCode = "465739"
                    // Breakpoint Here, to variable from debugger type: e securityCode = "new code"
                    try! handler.sendVerifyCode(securityCode: securityCode, completion: { (result, cache) in
                        //_cache = cache
                        print(result.value!)
                        exp.fulfill()
                    })
                })
            })
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            // if you need to test loginCache method, uncomment lines [110, 121, 138] and set `logoutAfterTest = false'
            //self.testLoginCache(handler: handler, cache: _cache!)
            self.testGetMediaLikers(handler: handler)
//            if self.logoutAfterTest {
//                self.testLogout(handler: handler)
//            }
        }
    }
    
    func testSearch(username: String, handler: APIHandlerProtocol) {
        let exp = expectation(description: "testSearch() faild during timeout")
        do {
            try handler.searchUser(username: username, completion: { (result) in
                if result.isSucceeded {
                    result.value?.compactMap { print("username: ", $0.username )}
                }
                
                exp.fulfill()
            })
        } catch {
            print("Error: ", error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testLogout(handler: APIHandlerProtocol) {
        let exp = expectation(description: "logout() faild during timeout")
        do {
            try handler.logout(completion: { (result) in
                if result.isSucceeded {
                    print("[+]: logged out")
                } else {
                    print("[-] Logout failed: \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch {
            print(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testGetUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUser() faild during timeout")
        do {
            try handler.getUser(id: 8766457680, completion: { (result) in // swifty.tips pk: 9529571412
                if result.isSucceeded {
                    guard let user = result.value else { return }
                    print("followers: ", user.user!.followerCount!)
                    print("followings: ", user.user!.followingCount!)
                    print("medias: ", user.user!.mediaCount!)
                    //print("fullname: \(user.fullName!)")
                } else {
                    print("GetUser failed: \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch let error as CustomErrors {
            print(error.localizedDescription)
            exp.fulfill()
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserFollowing(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUserFollowing() faild during timeout")
        do {
            try handler.getUserFollowing(username: "mehdi.makhdumi", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 1), searchQuery: "", completion: { (result) in
                if result.isSucceeded {
                    guard let following = result.value else { return }
                    print("[+] following count: \(following.count)")
                } else {
                    print("[-] \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserFollowers(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUserFollowing() faild during timeout")
        do {
            try handler.getUserFollowers(username: "swiftyinsta", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 15), searchQuery: "", completion: { (result) in
                if result.isSucceeded {
                    guard let followers = result.value else { return }
                    print("[+] followers count: \(followers.count)")
                    followers.forEach({ (follower) in
                        print(String(format: "name: %@\nuser_id: %ld", follower.fullName!, follower.pk!))
                    })
                } else {
                    print("[-] \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testRemoveFollower(handler: APIHandlerProtocol) {
        let exp = expectation(description: "removeFollower() faild during timeout")
        do {
            try handler.removeFollower(userId: 2291962059, completion: { (result) in
                if result.isSucceeded {
                    print("[+] user unfollowed")
                }
                
                print(result)
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetCurrentUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getCurrentUser() faild during timeout")
        do {
            try handler.getCurrentUser(completion: { (result) in
                if result.isSucceeded {
                    print("[+] user email: \(result.value!.user!.email!)")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserInfoById(handler: APIHandlerProtocol) {
        let id = 8766457680
        let exp = expectation(description: "getRankedDirectRecipients() faild during timeout")
        do {
            try handler.getUser(id: id, completion: { (result) in
                if result.isSucceeded {
                    print("[+] caption: \(result.value!.user!.biography!)")
                } else {
                    print(result.info.error)
                    print(result.info.message)
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testFollowUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "followUser() faild during timeout")
        let usernameToFollow = "username"
        do {
            // FIXME: Follow/Unfollow
            try handler.getUser(username: usernameToFollow, completion: { (user) in
                //unFollowUser(_,_)
                try? handler.followUser(userId: user.value!.pk!, completion: { (result) in
                    if user.isSucceeded {
                        if result.isSucceeded {
                            print("[+] following: \(result.value!.friendshipStatus!.following!)]")
                            print("[+] outgoing request: \(result.value!.friendshipStatus!.outgoingRequest!)")
                        } else {
                            print(result.info.message)
                        }
                    } else {
                        print(user.info.message)
                    }
                    
                    exp.fulfill()
                })
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testFriendshipStatus(handler: APIHandlerProtocol) {
        let exp = expectation(description: "friendshipStatus() faild during timeout")
        let usernameToCheck = "username"
        do {
            try handler.getUser(username: usernameToCheck, completion: { (user) in
                try? handler.getFriendshipStatus(of: user.value!.pk!, completion: { (result) in
                    if user.isSucceeded {
                        if result.isSucceeded {
                            print("[+] following: \(result.value!.following!)")
                            print("[+] followed by: \(result.value!.followedBy!)")
                        } else {
                            print(result.info.message)
                        }
                    } else {
                        print(user.info.message)
                    }
                    
                    exp.fulfill()
                })
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testBlockUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "friendshipStatus() faild during timeout")
        let userToBlock = "username"
        do {
            try handler.getUser(username: userToBlock, completion: { (user) in
                if user.isSucceeded {
                    //handler.unBlock(_,_)
                    try? handler.block(userId: user.value!.pk!, completion: { (result) in
                        print("[+] block status: \(result.value!.friendshipStatus!.blocking!)")
                        exp.fulfill()
                    })
                }
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserTags(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUserTags() faild during timeout")
        let userToGetTags = "username"
        do {
            try handler.getUser(username: userToGetTags, completion: { (user) in
                if user.isSucceeded {
                    try? handler.getUserTags(userId: user.value!.pk!, paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5), completion: { (result) in
                        if result.isSucceeded {
                            print("[+] first page items: \(result.value!.first!.totalCount!)")
                        }
                        exp.fulfill()
                    })
                }
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    // ----------------------------
    // MARK: - Feed Handler Methods
    
    func testGetExploreFeed(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getExploreFeed() faild during timeout")
        do {
            try handler.getExploreFeeds(paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5)) { (result) in
                if result.isSucceeded {
                    print("[+] Data received.")
                } else {
                    print("[-] \(result.info)")
                }
                exp.fulfill()
            }
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetTagFeed(handler: APIHandlerProtocol, tag: String) {
        let exp = expectation(description: "getTagFeed() faild during timeout")
        do {
            try handler.getTagFeed(tagName: tag, paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5), completion: { (result) in
                if result.isSucceeded {
                    print("[+] first username of each page who used this tagname:")
                    _ = result.value!.map { print("[+] \($0.items!.first!.caption!.user!.fullName!)") }
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserTimeLine(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getTimeLine() faild during timeout")
        do {
            try handler.getUserTimeLine(paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5)) { (result) in
                if result.isSucceeded {
                    print("[+] Data received.")
                } else {
                    print("[-] \(result.info)")
                }
                exp.fulfill()
            }
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    // -----------------------------
    // MARK: - Media Handler Methods
    
    func testGetUserMedia(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUserMedia() faild during timeout")
        do {
            try handler.getUserMedia(for: "apple", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 1)) { (result) in
                if result.isSucceeded {
                    print(result.value!)
                    print("[+] number of pages that include medias: \(result.value!.count)")
                }
                exp.fulfill()
            }
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetMediaInfo(handler: APIHandlerProtocol, id: String) {
        let exp = expectation(description: "getMediaInfo(id) faild during timeout")
        do {
            try handler.getMediaInfo(mediaId: id, completion: { (result) in
                if result.isSucceeded {
                    print("[+] media url: \(result.value!.imageVersions2!.candidates!.first!.url!)")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentActivities(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getRecentActivities() faild during timeout")
        do {
            try handler.getRecentFollowingActivities(paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5)) { (result) in
                if result.isSucceeded {
                    print("[+] \(result.value!)")
                }
                exp.fulfill()
            }
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentFollowingActivities(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getRecentFollowingActivities() faild during timeout")
        do {
            try handler.getRecentFollowingActivities(paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5)) { (result) in
                if result.isSucceeded {
                    print("[+] \(result.value!)")
                }
                exp.fulfill()
            }
        } catch {
            print(error.localizedDescription)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testLikeMedia(handler: APIHandlerProtocol) {
        let mediaId = "1909062118116718858_8766457680"
        let exp = expectation(description: "likeMedia() faild during timeout")
        do {
            // FIXME: Like/Unlike Media
            // handler.unLikeMedia...
            try handler.likeMedia(mediaId: mediaId, completion: { (result) in
                if result {
                    print("[+] media liked")
                } else {
                    print("[-] can not like media.]")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetMediaLikers(handler: APIHandlerProtocol) {
        let mediaId = "1920671942680208682_8766457680"
        let exp = expectation(description: "getMediaLikers() faild during timeout")
        
        do {
            try handler.getMediaLikers(mediaId: mediaId, completion: { (result) in
                print(result)
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testUploadVideo(handler: APIHandlerProtocol) {
        print("[+] uploadVideo testing ...")
        let exp = expectation(description: "testUploadVideo() faild during timeout")
        let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
        let videoUrl = URL(fileURLWithPath: (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/video.mp4")
        let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/2.jpg"
        let image = UIImage(contentsOfFile: imagePath)
        let photo = InstaPhoto(image: image!, caption: "", width: 1, height: 1)
        let video = try! InstaVideo.init(data: Data.init(contentsOf: videoUrl), name: "video.mp4", caption: "just uploaded a video from framework", muted: false, width: 0, height: 0, type: 0)
        do {
            try handler.uploadVideo(video: video, imageThumbnail: photo, caption: "just uploaded a video from framework", completion: { (result) in
                print(result)
                exp.fulfill()
            })
        } catch {
            print("[-] failed: ", error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testUploadPhoto(handler: APIHandlerProtocol) {
        let exp = expectation(description: "uploadPhoto() faild during timeout")
        let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
        let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/1.jpg"
        let image = UIImage(contentsOfFile: imagePath)
        do {
            let photo = InstaPhoto(image: image!, caption: "caption for test.", width: 1, height: 1)
            try handler.uploadPhoto(photo: photo, completion: { (result) in
                if result.isSucceeded {
                    print("[+] upload status: \(result.value!.status!)")
                } else {
                    print(result.info.message)
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testUploadPhotoAlbum(handler: APIHandlerProtocol) {
        let exp = expectation(description: "uploadPhotoAlbum() faild during timeout")
        let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
        let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/1.jpg"
        let image = UIImage(contentsOfFile: imagePath)
        let photos: [InstaPhoto] = [InstaPhoto(image: image!, caption: "", width: 1, height: 1),
                                    InstaPhoto(image: image!, caption: "", width: 1, height: 1),
                                    InstaPhoto(image: image!, caption: "", width: 1, height: 1),
                                    InstaPhoto(image: image!, caption: "", width: 1, height: 1)]
        
        try! handler.uploadPhotoAlbum(photos: photos, caption: "another test for album", completion: { (result) in
            if result.isSucceeded {
                print("[+] status: \(result.value!.status!)")
            } else {
                print("[-] error: \(result.info.message)")
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testEditMedia(handler: APIHandlerProtocol) {
        let mediaId = "1920671942680208682_8766457680"
        let exp = expectation(description: "testEditMedia() faild during timeout")
        let tag = UserTags(in: [NewTag.init(user_id: 9529571412, position: [0.8, 0.8])], removed: [])
        try! handler.editMedia(mediaId: mediaId, caption: "final test for tag editing.", tags: tag, completion: { (result) in
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
//    func testUploadVideo(handler: APIHandlerProtocol) {
//        let exp = expectation(description: "testUploadVideo() faild during timeout")
//
//        try! handler.uploadVideo(video: nil, imageTumbnail: nil, caption: nil, completion: { (result) in
//            exp.fulfill()
//        })
//        waitForExpectations(timeout: 60) { (err) in
//            if let err = err {
//                fatalError(err.localizedDescription)
//            }
//
//            if self.logoutAfterTest {
//                self.testLogout(handler: handler)
//            }
//        }
//    }
    
    // -------------------------------
    // MARK: - Message Handler Methods
    
    func testGetDirectInbox(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getDirectInbox() faild during timeout")
        do {
            try handler.getDirectInbox(completion: { (result) in
                if result.isSucceeded {
                    print("[+] last item: \(String(describing: result.value!.inbox.threads?.first?.lastPermanentItem?.text))")
                }
                exp.fulfill()
            })
        } catch  {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testSendDirectMessage(handler: APIHandlerProtocol) {
        let exp = expectation(description: "sendDirectMessage() faild during timeout")
        do {
            try handler.getDirectInbox(completion: { (result) in
                if result.isSucceeded {
                    let firstUserId = result.value?.inbox.threads?.first?.items?.first?.userId!
                    let threadId = result.value?.inbox.threads?.first?.threadId!
                    try? handler.sendDirect(to: String(firstUserId!), in: threadId!, with: "hello from swiftyinsta", completion: { (result) in
                        
                    })
                }
                exp.fulfill()
            })
        } catch  {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetDirectThreadById(handler: APIHandlerProtocol) {
        let threadId = "340282366841710300949128268428414320315"
        let exp = expectation(description: "getDirectThreadById() faild during timeout")
        do {
            try handler.getDirectThreadById(threadId: threadId, completion: { (result) in
                if result.isSucceeded {
                    print("[+] Conversation: \(String(describing: result.value!.thread))")
                } else {
                    print(result.info.message)
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentDirectRecipients(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getRecentDirectRecipients() faild during timeout")
        do {
            try handler.getRecentDirectRecipients(completion: { (result) in
                if result.isSucceeded {
                    print(result.value!)
                } else {
                    print(result.info.message)
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRankedDirectRecipients(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getRankedDirectRecipients() faild during timeout")
        do {
            try handler.getRankedDirectRecipients(completion: { (result) in
                if result.isSucceeded {
                    print(result.value!)
                } else {
                    print(result.info.message)
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    // -------------------------------
    // MARK: - Comment Handler Methods
    
    func testGetMediaComments(handler: APIHandlerProtocol) {
        let mediaId = "1909062118116718858_8766457680"
        let exp = expectation(description: "likeMedia() faild during timeout")
        do {
            try handler.getMediaComments(mediaId: mediaId, paginationParameter:  PaginationParameters.maxPagesToLoad(maxPages: 5), completion: { (result) in
                print("[+] first comment: \(result.value!.first!.comments!.first!)")
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testAddRemoveComment(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testAddComment() faild during timeout")
        let mediaId = "1909062118116718858"
        //let commentId = "18004184605045547"
        
        try! handler.addComment(mediaId: mediaId, comment: "test for receive comment id", completion: { (result) in
            print("[+] status: \(result.value!.status!)")
            print("[+] comment id: \(result.value!.comment!.pk!)")
            exp.fulfill()
        })
        
        // FIXME: Delete Comment
        //        try! handler.deleteComment(mediaId: mediaId, commentPk: commentId, completion: { (result) in
        //            exp.fulfill()
        //        })
        
        // FIXME: Delete Media
        //        try! handler.deleteMedia(mediaId: mediaId, mediaType: .image, completion: { (result) in
        //            exp.fulfill()
        //        })
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    // -------------------------------
    // MARK: - Profile Handler Methods
    
    func testSetProfilePublic(handler: APIHandlerProtocol) {
        let exp = expectation(description: "setProfilePublic() faild during timeout")
        do {
            // FIXME: Change Privacy Mode
            // try handler.setAccountPrivate
            try handler.setAccountPublic(completion: { (result) in
                if result.isSucceeded {
                    print(result.value!.user!.biography!)
                }
            })
            exp.fulfill()
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testChangePassword(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getRankedDirectRecipients() faild during timeout")
        do {
            try handler.setNewPassword(oldPassword: "qqqqqqq", newPassword: "123456", completion: { (result) in
                if result.isSucceeded {
                    print("[+] password changed.")
                } else {
                    print("[-] \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testEditProfile(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testEditProfile() faild during timeout")
        do {
            try handler.editProfile(name: "SwiftyInstaa", biography: "Private and Tokenless Instagram Library", url: "https://github.com/TheM4hd1/SwiftyInsta", email: "swiftyinsta@github.com", phone: "", gender: .male, newUsername: "", completion: { (result) in
                if result.isSucceeded {
                    print("[+] profile edited.")
                } else {
                    print("[-] fail to edit profile: \(result.info.error)")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testEditBiography(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testEditBiographyc() faild during timeout")
        do {
            try handler.editBiography(text: "Private Instagram API Library", completion: { (result) in
                print("bio changed: \(result.value!)")
                exp.fulfill()
            })
        } catch {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testUploadProfilePicture(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testUploadProfilePicture() faild during timeout")
        let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
        let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/1.jpg"
        
        do {
            let image = UIImage(contentsOfFile: imagePath)
            try handler.uploadProfilePicture(photo: InstaPhoto(image: image!, caption: "", width: 0, height: 0), completion: { (result) in
                if result.isSucceeded {
                    print("[+] uploaded: true")
                } else {
                    print("[-] \(result.info.message)")
                }
                exp.fulfill()
            })
        } catch {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    // ------------------------------
    // MARK: - Story Handler Methods
    
    func testGetStoryFeed(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testGetStoryFeed() faild during timeout")
        do {
            try handler.getStoryFeed { (result) in
                if result.isSucceeded {
                    print("[+] available stories: \(result.value!.tray!.count)")
                } else {
                    print(result.info.message)
                }
                exp.fulfill()
            }
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserStory(handler: APIHandlerProtocol) {
        let exp = expectation(description: "getUserStory() faild during timeout")
        do {
            try handler.getUser(username: "swiftyinsta", completion: { (user) in
                
                // Test Get Story Reel
//                try? handler.getUserStoryReelFeed(userId: user.value!.pk!, completion: { (result) in
//                    exp.fulfill()
//                })
                
                try? handler.getUserStory(userId: user.value!.pk!, completion: { (result) in
                    let items = result.value!.items!
                    items.forEach({ (item) in
                        let mediatype = String(item.mediaType!)
                        if mediatype == MediaTypes.image.rawValue {
                            print(item.imageVersions2!.candidates!)
                            // handle resolution here or just take first one.
                            //let url = item.imageVersions2!.candidates!.first!.url!
                        } else if mediatype == MediaTypes.video.rawValue {
                            print(item.videoVersions!)
                            // handle resolution or just take first one
                            //let url = item.videoVersions!.first!.url!
                        }
                    })
                    exp.fulfill()
                })
                
                // Test Upload Photo Story
//                let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
//                let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/1.jpg"
//                let image = UIImage(contentsOfFile: imagePath)
//                try? handler.uploadStoryPhoto(photo: InstaPhoto(image: image!, caption: "caption", width: 1, height: 1), completion: { (result) in
//                    print(result.value!.status!)
//                    exp.fulfill()
//                })
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetStoryViewers(handler: APIHandlerProtocol) {
        let exp = expectation(description: "testGetStoryViewers() faild during timeout")
        let storyPk = "2022853344112336157"
        
        try! handler.getStoryViewers(storyPk: storyPk, completion: { (result) in
            result.value!.users!.forEach{ print($0.username!) }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                fatalError(err.localizedDescription)
            }
            
            if self.logoutAfterTest {
                self.testLogout(handler: handler)
            }
        }
    }
}
