//
//  PathHelper.swift
//  kAR
//
//  Created by Tomas Vajdicka on 25/06/2019.
//  Copyright © 2019 rebel.io. All rights reserved.
//

import Foundation

class PathHelper {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
