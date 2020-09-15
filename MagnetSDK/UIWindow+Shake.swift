//
//  UIWindow+Shake.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 15/09/2020.
//  Copyright © 2020 e.d.neutrum. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("DeviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}
