//
//  AndroidDeviceGenerator.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct AndroidDeviceGenerator {
    static let deviceNames: [Devices] = Devices.allCases

    static let deviceCollection: [Devices: AndroidDeviceModel] = [
        Devices.lgOptimusG: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "5b971484-ad0f-41fa-8886-313e9e91f5b9")!,
            deviceGuid: UUID.init(uuidString: "202d7022-3533-4450-91bd-0344112e0deb")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "geehrc",
            androidBootLoader: "MAKOZ10f",
            deviceBrand: "LGE",
            deviceId: "",
            deviceModel: "LG-LS970",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "cm_ls970",
            frimwareBrand: "cm_ls970",
            frimwareFingerprint: "google/occam/mako:4.2.2/JDQ39/573038:user/release-keys",
            frimwareTags: "test-keys",
            frimwareType: "userdebug",
            hardwareManufacturer: "LGE",
            hardwareModel: "LG-LS970"
        ),
        Devices.nexus7gen2: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "97dd4f8a-af3f-4cfe-8be3-c34c38110346")!,
            deviceGuid: UUID.init(uuidString: "82c2dbb7-35fc-4544-8b6f-4d8606ea1f7f")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "flo",
            androidBootLoader: "FLO-04.07",
            deviceBrand: "google",
            deviceId: "",
            deviceModel: "Nexus 7",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "razor",
            frimwareBrand: "razor",
            frimwareFingerprint: "google/razor/flo:6.0.1/MOB30P/2960889:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "asus",
            hardwareModel: "Nexus 7"
        ),
        Devices.htc10: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "3e90b5f5-23c3-4fd1-b9ba-8e090a1fa397")!,
            deviceGuid: UUID.init(uuidString: "a91cd29b-2070-4c4e-b4cb-35335b2a38dc")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "msm8996",
            androidBootLoader: "1.0.0.0000",
            deviceBrand: "HTC",
            deviceId: "",
            deviceModel: "HTC 10",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "pmewl_00531",
            frimwareBrand: "pmewl_00531",
            frimwareFingerprint: "htc/pmewl_00531/htc_pmewl:6.0.1/MMB29M/770927.1:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "HTC",
            hardwareModel: "HTC 10"
        ),
        Devices.galaxy6: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "9ade42fb-09de-4931-8526-8f7c1bd3ce2a")!,
            deviceGuid: UUID.init(uuidString: "505cbe9d-487c-49d4-8f2c-b1cc166d1094")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "universal7420",
            androidBootLoader: "G920FXXU3DPEK",
            deviceBrand: "samsung",
            deviceId: "",
            deviceModel: "zeroflte",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "SM-G920F",
            frimwareBrand: "zerofltexx",
            frimwareFingerprint: "samsung/zerofltexx/zeroflte:6.0.1/MMB29K/G920FXXU3DPEK:user/release-keys",
            frimwareTags: "dev-keys",
            frimwareType: "user",
            hardwareManufacturer: "samsung",
            hardwareModel: "samsungexynos7420"
        ),
        Devices.galaxy5: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "141023a2-153b-4e92-ae64-893553eaa9db")!,
            deviceGuid: UUID.init(uuidString: "d13d1596-0983-4e59-825f-bd7cd559106b")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "MSM8974",
            androidBootLoader: "G900FXXU1CPEH",
            deviceBrand: "samsung",
            deviceId: "",
            deviceModel: "SM-G900F",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "kltexx",
            frimwareBrand: "kltexx",
            frimwareFingerprint: "samsung/kltexx/klte:6.0.1/MMB29M/G900FXXU1CPEH:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "samsung",
            hardwareModel: "SM-G900F"
        ),
        Devices.lgOptimusF6: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "17c27d7a-788d-4430-bcb0-6ae605ef0b01")!,
            deviceGuid: UUID.init(uuidString: "5ccdd80f-389e-4156-b070-fddab5fb7ed9")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "f6t",
            androidBootLoader: "1.0.0.0000",
            deviceBrand: "lge",
            deviceId: "",
            deviceModel: "LG-D500",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "f6_tmo_us",
            frimwareBrand: "f6_tmo_us",
            frimwareFingerprint: "lge/f6_tmo_us/f6:4.1.2/JZO54K/D50010h.1384764249:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "LGE",
            hardwareModel: "LG-D500"
        ),
        Devices.galaxyTab: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "849a7ae1-cf94-4dd5-a977-a2f3e8363e66")!,
            deviceGuid: UUID.init(uuidString: "c319490f-6f09-467b-b2a5-6f1db13348e9")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "universal5420",
            androidBootLoader: "T705XXU1BOL2",
            deviceBrand: "samsung",
            deviceId: RequestMessageModel.generateDeviceIdFromGuid(guid: UUID.init(uuidString: "c319490f-6f09-467b-b2a5-6f1db13348e9")!),
            deviceModel: "Samsung Galaxy Tab S 8.4 LTE",
            deviceModelBoot: "universal5420",
            deviceModelIdentifier: "LRX22G.T705XXU1BOL2",
            frimwareBrand: "Samsung Galaxy Tab S 8.4 LTE",
            frimwareFingerprint: "samsung/klimtltexx/klimtlte:5.0.2/LRX22G/T705XXU1BOL2:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "samsung",
            hardwareModel: "SM-T705"
        ),
        Devices.samsungNote3: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "28484284-e646-4a29-88fc-76c2666d5ab3")!,
            deviceGuid: UUID.init(uuidString: "7f585e77-becf-4137-bf1f-84ab72e35eb4")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "MSM8974",
            androidBootLoader: "N900PVPUEOK2",
            deviceBrand: "samsung",
            deviceId: RequestMessageModel.generateDeviceIdFromGuid(guid: UUID.init(uuidString: "7f585e77-becf-4137-bf1f-84ab72e35eb4")!),
            deviceModel: "SM-N900P",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "cm_hltespr",
            frimwareBrand: "cm_hltespr",
            frimwareFingerprint: "samsung/hltespr/hltespr:5.0/LRX21V/N900PVPUEOH1:user/release-keys",
            frimwareTags: "test-keys",
            frimwareType: "user",
            hardwareManufacturer: "samsung",
            hardwareModel: "SM-N900P"
        ),
        Devices.nexus4Chroma: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "7fb2eb38-04ab-4c51-bd0c-694c7da2187e")!,
            deviceGuid: UUID.init(uuidString: "2c4ae214-c037-486c-a335-76a1f6973445")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "MAKO",
            androidBootLoader: "MAKOZ30f",
            deviceBrand: "google",
            deviceId: RequestMessageModel.generateDeviceIdFromGuid(guid: UUID.init(uuidString: "2c4ae214-c037-486c-a335-76a1f6973445")!),
            deviceModel: "Nexus 4",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "occam",
            frimwareBrand: "occam",
            frimwareFingerprint: "google/occam/mako:6.0.1/MOB30Y/3067468:user/release-keys",
            frimwareTags: "test-keys",
            frimwareType: "userdebug",
            hardwareManufacturer: "LGE",
            hardwareModel: "Nexus 4"
        ),
        Devices.sonyZ3Compact: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "8afad275-4fca-49e6-a5e0-3b2bbfe6e9f2")!,
            deviceGuid: UUID.init(uuidString: "bccfcc1c-8188-42fa-a14e-e238c847c358")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "MSM8974",
            androidBootLoader: "s1",
            deviceBrand: "docomo",
            deviceId: "",
            deviceModel: "SO-02G",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "SO-02G",
            frimwareBrand: "SO-02G",
            frimwareFingerprint: "docomo/SO-02G/SO-02G:5.0.2/23.1.B.1.317/2161656255:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "Sony",
            hardwareModel: "SO-02G"
        ),
        Devices.xperiaZ5: AndroidDeviceModel(
            phoneGuid: UUID.init(uuidString: "aaeb4dfb-a93d-4bd6-9147-1a3aaee60510")!,
            deviceGuid: UUID.init(uuidString: "78178fef-aa0c-4691-9c00-16482c25ce24")!,
            googleAdId: UUID.init(),
            rankToken: UUID.init(),
            androidBoardName: "msm8994",
            androidBootLoader: "s1",
            deviceBrand: "Sony",
            deviceId: "",
            deviceModel: "E6653",
            deviceModelBoot: "qcom",
            deviceModelIdentifier: "E6653",
            frimwareBrand: "E6653",
            frimwareFingerprint: "Sony/E6653/E6653:6.0.1/32.2.A.0.224/456768306:user/release-keys",
            frimwareTags: "release-keys",
            frimwareType: "user",
            hardwareManufacturer: "Sony",
            hardwareModel: "E6653"
        )
    ]

    static func getRandomAndroidDevice() -> AndroidDeviceModel {
        let randomDeviceName = deviceNames.randomElement() // We can safely unwrap it. Collection isn't empty.
        return deviceCollection[randomDeviceName!]!
    }

    static func getByName(deviceName: Devices) -> AndroidDeviceModel {
        return deviceCollection[deviceName]!
    }

    static func getById(deviceId: String) throws -> AndroidDeviceModel {
        let devices = deviceCollection.filter {$0.value.deviceId == deviceId}
        if let firstDevice = devices.first {
            return firstDevice.value
        }
        throw CustomErrors.runTimeError("deviceId doesn't exist.")
    }
}
