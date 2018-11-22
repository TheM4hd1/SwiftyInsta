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
    
    func testLogin() {
        HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
            HTTPCookieStorage.shared.deleteCookie(cookie)
        })
        
        let exp = expectation(description: "\n\nLogin() faild during timeout\n\n")
        let user = SessionStorage.create(username: "swiftyinsta", password: "qqqqqqq")
        let handler = try! APIBuilder().createBuilder().setHttpHandler(config: .default).setRequestDelay(delay: .default).setUser(user: user).build()
        
        do {
            try handler.login { (result) in
                if result.isSucceeded {
                    print("[+]: logged in")
                } else {
                    print("[-] Login failed: \(result.info.message)")
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
            } else {
                //self.testGetUser(handler: handler)
                //self.testGetUserFollowing(handler: handler)
                //self.testGetUserFollowers(handler: handler)
                //self.testGetCurrentUser(handler: handler)
                //self.testGetExploreFeed(handler: handler)
                //self.testGetUserTimeLine(handler: handler)
                //self.testGetUserMedia(handler: handler)
                //self.testGetMediaInfo(handler: handler, id: "1909062118116718858_8766457680")
                //self.testGetTagFeed(handler: handler, tag: "github")
                //self.testGetRecentActivities(handler: handler)
                //self.testGetRecentFollowingActivities(handler: handler)
                //self.testGetDirectInbox(handler: handler)
                //self.testSendDirectMessage(handler: handler)
                //self.testGetDirectThreadById(handler: handler)
                //self.testGetRecentDirectRecipients(handler: handler)
                //self.testGetRankedDirectRecipients(handler: handler)
                //self.testSetProfilePublic(handler: handler)
                //self.testChangePassword(handler: handler)
                //self.testGetUserInfoById(handler: handler)
                //self.testLikeMedia(handler: handler)
                //self.testGetMediaComments(handler: handler)
                //self.testFollowUser(handler: handler)
                //self.testFriendshipStatus(handler: handler)
                //self.testBlockUser(handler: handler)
                //self.testGetUserTags(handler: handler)
                //self.testUploadPhoto(handler: handler)
                //self.testUploadPhotoAlbum(handler: handler)
                self.testAddComment(handler: handler)
            }
        }
    }
    
    func testLogout(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nLogout() faild during timeout\n\n")
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
        let exp = expectation(description: "\n\nGetUser() faild during timeout\n\n")
        do {
            try handler.getUser(username: "swiftyinsta", completion: { (result) in
                if result.isSucceeded {
                    guard let user = result.value else { return }
                    print("fullname: \(user.fullName!)")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserFollowing(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetUserFollowing() faild during timeout\n\n")
        do {
            try handler.getUserFollowing(username: "", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 1), searchQuery: "", completion: { (result) in
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserFollowers(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetUserFollowing() faild during timeout\n\n")
        do {
            try handler.getUserFollowers(username: "", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 15), searchQuery: "", completion: { (result) in
                if result.isSucceeded {
                    guard let followers = result.value else { return }
                    print("[+] followers count: \(followers.count)")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetCurrentUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetCurrentUser() faild during timeout\n\n")
        do {
            try handler.getCurrentUser(completion: { (result) in
                if result.isSucceeded {
                    print("[+] user email: \(result.value!.user.email!)")
                }
                exp.fulfill()
            })
        } catch {
            print("[-] \(error.localizedDescription)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetExploreFeed(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetExploreFeed() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserTimeLine(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetTimeLine() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserMedia(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetUserMedia() faild during timeout\n\n")
        do {
            try handler.getUserMedia(for: "swiftyinsta", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 5)) { (result) in
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetMediaInfo(handler: APIHandlerProtocol, id: String) {
        let exp = expectation(description: "\n\ngetMediaInfo(id) faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetTagFeed(handler: APIHandlerProtocol, tag: String) {
        let exp = expectation(description: "\n\ngetTagFeed() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentActivities(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetRecentActivities() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentFollowingActivities(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetRecentFollowingActivities() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetDirectInbox(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetDirectInbox() faild during timeout\n\n")
        
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testSendDirectMessage(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nsendDirectMessage() faild during timeout\n\n")
        
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetDirectThreadById(handler: APIHandlerProtocol) {
        let threadId = "340282366841710300949128268428414320315"
        let exp = expectation(description: "\n\ngetDirectThreadById() faild during timeout\n\n")
        
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRecentDirectRecipients(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetRecentDirectRecipients() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetRankedDirectRecipients(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetRankedDirectRecipients() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testSetProfilePublic(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nsetProfilePublic() faild during timeout\n\n")
        do {
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testChangePassword(handler: APIHandlerProtocol) {
         let exp = expectation(description: "\n\ngetRankedDirectRecipients() faild during timeout\n\n")
        
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserInfoById(handler: APIHandlerProtocol) {
        let id = 8766457680
        let exp = expectation(description: "\n\ngetRankedDirectRecipients() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testLikeMedia(handler: APIHandlerProtocol) {
        let mediaId = "1909062118116718858_8766457680"
        let exp = expectation(description: "\n\nlikeMedia() faild during timeout\n\n")
        do {
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetMediaComments(handler: APIHandlerProtocol) {
        let mediaId = "1909062118116718858_8766457680"
        let exp = expectation(description: "\n\nlikeMedia() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testFollowUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nfollowUser() faild during timeout\n\n")
        let usernameToFollow = "username"
        do {
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testFriendshipStatus(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nfriendshipStatus() faild during timeout\n\n")
        let usernameToCheck = "username"
        do {
            try handler.getUser(username: usernameToCheck, completion: { (user) in
                try? handler.getFriendshipStatus(of: user.value!.pk!, completion: { (result) in
                    if user.isSucceeded {
                        if result.isSucceeded {
                            print("[+] following: \(result.value!.following!)]")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testBlockUser(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nfriendshipStatus() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testGetUserTags(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ngetUserTags() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testUploadPhoto(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nuploadPhoto() faild during timeout\n\n")
        let myBundle = Bundle.init(identifier: "com.TheM4hd1.SwiftyInsta")
        let imagePath = (myBundle?.path(forResource: "testbundle", ofType: "bundle"))! + "/1.jpg"
        let image = UIImage(contentsOfFile: imagePath)
        do {
            try handler.uploadPhoto(photo: InstaPhoto(image: image!, caption: "caption for test.", width: 1, height: 1), completion: { (result) in
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testUploadPhotoAlbum(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\nuploadPhotoAlbum() faild during timeout\n\n")
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
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
    
    func testAddComment(handler: APIHandlerProtocol) {
        let exp = expectation(description: "\n\ntestAddComment() faild during timeout\n\n")
        let mediaId = "1909062118116718858"
        let commentId = "18004184605045547"
        
        try! handler.addComment(mediaId: mediaId, comment: "test for receive comment id", completion: { (result) in
            print("[+] status: \(result.value!.status!)")
            print("[+] comment id: \(result.value!.comment!.pk!)") // 18004184605045547
            exp.fulfill()
        })
        
//        try! handler.deleteComment(mediaId: mediaId, commentPk: commentId, completion: { (result) in
//            exp.fulfill()
//        })
        
        waitForExpectations(timeout: 60) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.testLogout(handler: handler)
            }
        }
    }
}
