//
//  CreateAccountModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/17/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct CreateAccountModel {
    public let username: String
    public let password: String
    public let email: String
    public let firstName: String
    
    public init(username: String, password: String, email: String, firstName: String) {
        self.username = username
        self.password = password
        self.email = email
        self.firstName = firstName
    }
}
