//
//  NetworkHelper.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 15/09/2020.
//  Copyright © 2020 e.d.neutrum. All rights reserved.
//

import Foundation
import NotificationCenter
import SystemConfiguration
import Network

public enum NetworkType {
    case celullar
    case wifi
    case ethernet
    case other
}

public enum NetworkState {
    case online
    case offline
}

class NetworkHelper {
    static let shared = NetworkHelper()
    
    private var events = Events.shared
    
    var monitor: NWPathMonitor?
    
    func start(){
        monitor?.cancel()
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status != .satisfied {
            // Offline
                self.events.onNetworkStateChanged(.offline)
            } else if path.usesInterfaceType(.cellular) {
                // Celullar
                if (true == Settings().useMobileData) {
                    self.events.onNetworkStateChanged(.online)
                } else {
                    self.events.onNetworkStateChanged(.offline)
                }
            }
            else if path.usesInterfaceType(.wifi) {
                // Wifi
                self.events.onNetworkStateChanged(.online)
            }
        }
            
        monitor?.start(queue: DispatchQueue.global(qos: .background))
    }
}
