//
//  UserAgentHelper.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 12/5/20.
//  Copyright © 2020 Mahdi. All rights reserved.
//

#if os(iOS)
import UIKit

struct UserAgentHelper {
    static func generate() -> String {
        // swiftlint:disable line_length
        return "Instagram 160.1.0.31.120 (\(getIdentifier()); iOS \(getOsVersion()); en_US; en-US; scale=2.00; \(getScreenSize()); 246979827) AppleWebKit/420+"
        // swiftlint:enable line_length
    }

    fileprivate static func getIdentifier() -> String {
        #if !((arch(i386)) || arch(x86_64))
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce(into: "") { (identifier, element) in
            if let value = element.value as? Int8, value != 0 {
                identifier += String(UnicodeScalar(UInt8(value)))
            }
        }
        return identifier
        #else
        return "iPhone9,1"
        #endif
    }

    fileprivate static func getOsVersion() -> String {
        return UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
    }

    fileprivate static func getScreenSize(scale: CGFloat = 2.0) -> String {
        let width = Int(UIScreen.main.bounds.width * scale)
        let height = Int(UIScreen.main.bounds.height * scale)
        return String(format: "%dx%d", arguments: [width, height])
    }
}

#endif
