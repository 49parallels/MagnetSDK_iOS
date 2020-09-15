//
//  MagnetRecord.swift
//  kAR
//
//  Created by Tomas Vajdicka on 24/06/2019.
//  Copyright © 2019 rebel.io. All rights reserved.
//

import UIKit
import ARKit

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
    
    func asReference() -> ARReferenceImage? {
        do {
            let documentsDirectory = PathHelper.getDocumentsDirectory()
            let fileUrl = documentsDirectory.appendingPathComponent(key)
            let imageData = try Data(contentsOf: fileUrl)
            guard let image = UIImage(data: imageData) else { return nil}
            guard let cgImage = image.cgImage else { return nil}
            let orientation = MagnetOrientation.UP
            let customARReferenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: CGFloat(physicalSize))
            customARReferenceImage.name = key
            customARReferenceImage.accessibilityValue = orientation.rawValue
            return customARReferenceImage
        } catch {
            print("Error Generating Image == \(error)")
        }
        return nil
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
