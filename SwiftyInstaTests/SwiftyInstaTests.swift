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
        let user = SessionStorage.create(username: "", password: "")
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
                self.testGetUserFollowers(handler: handler)
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
}
