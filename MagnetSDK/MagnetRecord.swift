//
//  MagnetRecord.swift
//  kAR
//
//  Created by Tomas Vajdicka on 24/06/2019.
//  Copyright © 2019 rebel.io. All rights reserved.
//

import UIKit

struct MagnetRecord: Codable {
    var key: String
    var physicalSize: Double
    
    enum CodingKeys: String, CodingKey {
         case key = "id"
         case physicalSize = "physicalSize"
    }
}

extension MagnetRecord {
    func exists() -> Bool {
        return MagnetDB.shared.exists(key: self.key)
    }
}

struct MagneticField: Codable {
    var magnets: Array<MagnetRecord>
}

extension MagnetRecord: SQLTable {
    static var createStatement: String {
      return """
      CREATE TABLE IF NOT EXISTS Magnet(
        id INTEGER PRIMARY KEY NOT NULL,
        key CHAR(255),
        physicalSize DOUBLE
      );
      """
    }
}

//import RealmSwift
//
//@objcMembers class MagnetRecord: Object {
//    dynamic var id: String = ""
//    dynamic var photoKey: String = ""
//    dynamic var videoKey: String = ""
//    dynamic var photoWidth: String = ""
//
//    override class func primaryKey() -> String? {
//        return "id"
//    }
//
//    convenience init(id: String, photoKey: String, videoKey: String, photoWidth: String) {
//        self.init()
//        self.id = id
//        self.photoKey = photoKey
//        self.videoKey = videoKey
//        self.photoWidth = photoWidth
//    }
//}
