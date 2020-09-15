//
//  UserDefaultsHelper.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 15/09/2020.
//  Copyright © 2020 e.d.neutrum. All rights reserved.
//

import Foundation

final class UserDefaultsHelper {
    static let userDefaults = UserDefaults.init(suiteName: "com.49parallels.MagnetSDK")!
    static func setData<T>(value: T, key: Settings.Keys) {
       let defaults = UserDefaultsHelper.userDefaults
       defaults.set(value, forKey: key.rawValue)
    }
        
    static func getData<T>(type: T.Type, forKey: Settings.Keys) -> T? {
       let defaults = UserDefaultsHelper.userDefaults
       let value = defaults.object(forKey: forKey.rawValue) as? T
       return value
    }

    static func removeData(key: Settings.Keys) {
       let defaults = UserDefaultsHelper.userDefaults
       defaults.removeObject(forKey: key.rawValue)
    }
}
