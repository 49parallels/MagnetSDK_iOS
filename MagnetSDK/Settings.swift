//
//  Settings.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 15/09/2020.
//  Copyright © 2020 e.d.neutrum. All rights reserved.
//

import Foundation

public class Settings {
    
    enum Keys: String, CaseIterable {
        case soundOnOff
        case shakeToRestart
        case useMobileData
        case networkType
    }
    
    public var soundOn: Bool {
        get {
            return UserDefaultsHelper.getData(type: Bool.self, forKey: Keys.soundOnOff) ?? true
        }
        set(newValue) {
            UserDefaultsHelper.setData(value: newValue, key: Keys.soundOnOff)
        }
    }
    
    public var shakeToRestart: Bool {
        get {
            return UserDefaultsHelper.getData(type: Bool.self, forKey: Keys.shakeToRestart) ?? false
        }
        set(newValue) {
            UserDefaultsHelper.setData(value: newValue, key: Keys.shakeToRestart)
        }
    }
    
    public var useMobileData: Bool {
        get {
            return UserDefaultsHelper.getData(type: Bool.self, forKey: Keys.useMobileData) ?? true
        }
        set(newValue) {
            UserDefaultsHelper.setData(value: newValue, key: Keys.useMobileData)
            NetworkHelper.shared.start()
        }
    }
    

    public var currentNetworkType: NetworkType {
        get {
            return UserDefaultsHelper.getData(type: NetworkType.self, forKey: Keys.networkType) ?? .other
        }
        set(newValue) {
            UserDefaultsHelper.setData(value: newValue, key: Keys.networkType)
        }
    }
    
}
