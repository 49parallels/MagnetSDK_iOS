//
//  Events.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 15/09/2020.
//  Copyright © 2020 e.d.neutrum. All rights reserved.
//

import Foundation

public class Events {
    static let shared = Events()
    
    public var onAnchored: (String)->Void = { key in }
    public var onPlaying: (String, String)->Void = { (key,time)  in }
    public var onNetworkStateChanged: (NetworkState) ->Void = { isOnline in } {
        willSet {
            NetworkHelper.shared.start()
        }
    }
    public var onShake:()->() = {}
}
