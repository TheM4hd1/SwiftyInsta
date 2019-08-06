//
//  SupportedCapabilities.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 06/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

struct SupportedCapability: Codable {
    let name: String
    let value: String

    static func generate() -> [SupportedCapability] {
        var capabilities: [SupportedCapability] = []
        capabilities.append(SupportedCapability(name: "SUPPORTED_SDK_VERSIONS",
                                                value: ["13.0", "14.0", "15.0", "16.0", "17.0", "18.0", "19.0",
                                                        "20.0", "21.0", "22.0", "23.0", "24.0", "25.0", "26.0",
                                                        "27.0", "28.0", "29.0", "30.0", "31.0", "32.0", "33.0",
                                                        "34.0", "35.0", "36.0", "37.0", "38.0", "39.0", "40.0",
                                                        "41.0", "42.0", "43.0", "44.0", "45.0", "46.0", "47.0",
                                                        "48.0", "49.0", "50.0", "51.0", "52.0", "53.0", "54.0",
                                                        "55.0", "56.0", "57.0", "58.0"].joined(separator: ",")))
        capabilities.append(SupportedCapability(name: "FACE_TRACKER_VERSION", value: "12"))
        capabilities.append(SupportedCapability(name: "segmentation", value: "segmentation_enabled"))
        capabilities.append(SupportedCapability(name: "COMPRESSION", value: "ETC2_COMPRESSION"))
        capabilities.append(SupportedCapability(name: "world_tracker", value: "world_tracker_enabled"))
        capabilities.append(SupportedCapability(name: "gyroscope", value: "gyroscope_enabled"))
        return capabilities
    }
}
