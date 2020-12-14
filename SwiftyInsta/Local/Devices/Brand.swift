//
//  Brand.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 31/07/2019.
//  V. 2.0 by Stefano Bertagno on 7/31/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// HTC devices.
public enum HTC: DeviceCollection, DeviceGenerating, CaseIterable {
    /// The HTC 10.
    case ten

    /// All cases.
    public static var all: [DeviceCollection & DeviceGenerating] { return allCases }
    /// Generate the specific `Device`.
    public func generate() -> Device {
        switch self {
        case .ten:
            return .init(brand: "HTC",
                         model: "HTC 10",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "msm8996",
                         androidBootLoader: "1.0.0.0000",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "pmewl_00531",
                         firmwareBrand: "pmewl_00531",
                         firmwareFingerprint: "htc/pmewl_00531/htc_pmewl:6.0.1/MMB29M/770927.1:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "HTC",
                         hardwareModel: "HTC 10")
        }
    }
}
/// LG devices.
public enum LG: CaseIterable, DeviceCollection, DeviceGenerating {
    /// The LG Optimtus F6
    case optimusF6
    /// The LG Optimus G.
    case optimusG

    /// All cases.
    public static var all: [DeviceCollection & DeviceGenerating] { return allCases }
    /// Generate the specific `Device`.
    public func generate() -> Device {
        switch self {
        case .optimusF6:
            return .init(brand: "LGE",
                         model: "LG-D500",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "f6t",
                         androidBootLoader: "1.0.0.0000",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "f6_tmo_us",
                         firmwareBrand: "f6_tmo_us",
                         firmwareFingerprint: "lge/f6_tmo_us/f6:4.1.2/JZO54K/D50010h.1384764249:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "LGE",
                         hardwareModel: "LG-D500")
        case .optimusG:
            return .init(brand: "LGE",
                         model: "LG-LS970",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "geehrc",
                         androidBootLoader: "MAKOZ10f",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "cm_ls970",
                         firmwareBrand: "cm_ls970",
                         firmwareFingerprint: "google/occam/mako:4.2.2/JDQ39/573038:user/release-keys",
                         firmwareTags: "test-keys",
                         firmwareType: "userdebug",
                         hardwareManufacturer: "LGE",
                         hardwareModel: "LG-LS970")
        }
    }
}
/// Samsung devices.
public enum Samsung: CaseIterable, DeviceCollection, DeviceGenerating {
    /// The Samsung Galaxy Note 3.
    case galaxyNote3
    /// The Samsung Galaxy S5.
    case galaxyS5
    /// The Samsung Galaxy S6.
    case galaxyS6
    /// The Samsung Galaxy Tab.
    case galaxyTab

    /// All cases.
    public static var all: [DeviceCollection & DeviceGenerating] { return allCases }
    /// Generate the specific `Device`.
    public func generate() -> Device {
        switch self {
        case .galaxyNote3:
            return .init(brand: "samsung",
                         model: "SM-N900P",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "MSM8974",
                         androidBootLoader: "N900PVPUEOK2",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "cm_hltespr",
                         firmwareBrand: "cm_hltespr",
                         firmwareFingerprint: "samsung/hltespr/hltespr:5.0/LRX21V/N900PVPUEOH1:user/release-keys",
                         firmwareTags: "test-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "samsung",
                         hardwareModel: "SM-N900P")
        case .galaxyS5:
            return .init(brand: "samsung",
                         model: "zeroflte",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "universal7420",
                         androidBootLoader: "G920FXXU3DPEK",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "SM-G920F",
                         firmwareBrand: "zerofltexx",
                         firmwareFingerprint: "samsung/zerofltexx/zeroflte:6.0.1/MMB29K/G920FXXU3DPEK:user/release-keys",
                         firmwareTags: "dev-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "samsung",
                         hardwareModel: "samsungexynos7420")
        case .galaxyS6:
            return .init(brand: "samsung",
                         model: "SM-G900F",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "MSM8974",
                         androidBootLoader: "G900FXXU1CPEH",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "kltexx",
                         firmwareBrand: "kltexx",
                         firmwareFingerprint: "samsung/kltexx/klte:6.0.1/MMB29M/G900FXXU1CPEH:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "samsung",
                         hardwareModel: "SM-G900F")
        case .galaxyTab:
            return .init(brand: "samsung",
                         model: "Samsung Galaxy Tab S 8.4 LTE",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "universal5420",
                         androidBootLoader: "T705XXU1BOL2",
                         deviceModelBoot: "universal5420",
                         deviceModelIdentifier: "LRX22G.T705XXU1BOL2",
                         firmwareBrand: "Samsung Galaxy Tab S 8.4 LTE",
                         firmwareFingerprint: "samsung/klimtltexx/klimtlte:5.0.2/LRX22G/T705XXU1BOL2:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "samsung",
                         hardwareModel: "SM-T705")
        }
    }
}
/// Sony devices.
public enum Sony: CaseIterable, DeviceCollection, DeviceGenerating {
    /// The Xperia Z5.
    case xperiaZ5
    /// The Z3 Compact.
    case z3Compact

    /// All cases.
    public static var all: [DeviceCollection & DeviceGenerating] { return allCases }
    /// Generate the specific `Device`.
    public func generate() -> Device {
        switch self {
        case .xperiaZ5:
            return .init(brand: "Sony",
                         model: "E6653",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "MSM8974",
                         androidBootLoader: "s1",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "E6653",
                         firmwareBrand: "E6653",
                         firmwareFingerprint: "Sony/E6653/E6653:6.0.1/32.2.A.0.224/456768306:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "Sony",
                         hardwareModel: "E6653")
        case .z3Compact:
            return .init(brand: "docomo",
                         model: "SO-02G",
                         phoneGuid: UUID(),
                         deviceGuid: UUID(),
                         googleAdId: .init(),
                         rankToken: .init(),
                         androidBoardName: "MSM8974",
                         androidBootLoader: "s1",
                         deviceModelBoot: "qcom",
                         deviceModelIdentifier: "SO-02G",
                         firmwareBrand: "SO-02G",
                         firmwareFingerprint: "docomo/SO-02G/SO-02G:5.0.2/23.1.B.1.317/2161656255:user/release-keys",
                         firmwareTags: "release-keys",
                         firmwareType: "user",
                         hardwareManufacturer: "Sony",
                         hardwareModel: "SO-02G")
        }
    }
}
