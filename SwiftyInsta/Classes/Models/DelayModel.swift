//
//  DelayModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/25/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct DelayModel {
    public var min: Double = 1
    public var max: Double = 5
    public static let `default` = DelayModel(min: 1, max: 5)
    
    public init(min: Double, max: Double) {
        self.max = max
        self.min = min
    }
    
    func random() -> Double {
        return Double.random(in: min...max)
    }
}
