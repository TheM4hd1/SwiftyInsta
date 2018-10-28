//
//  DelayModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/25/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct DelayModel {
    var min: Double = 1
    var max: Double = 5
    
    func random() -> Double {
        return Double.random(in: min...max)
    }
}
