//
//  DelayModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/25/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct DelayModel {
    var min: Int = 1
    var max: Int = 5
    
    func random() -> Int {
        return Int.random(in: min...max)
    }
}
