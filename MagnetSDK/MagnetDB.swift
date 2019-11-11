//
//  MagnetDB.swift
//  Magnet
//
//  Created by e.d.neutrum on 04/11/2019.
//  Copyright © 2019 e.d.neutrum. All rights reserved.
//

import UIKit

class MagnetDB {
    static let shared = MagnetDB()
    var db:SQLiteDatabase!
    
    init(){}
    
    func configure() {
        self.openDb()
        self.createTable()
    }
    
    private func openDb() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let pathToDb = "\(path)/Magnets.sqlite3"
        
        do {
          db = try SQLiteDatabase.open(path: pathToDb)
          print("MagnetDB openDb() - Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(let message) {
          print("MagnetDB openDb() - Unable to open database:"+message)
        } catch {
          print("MagnetDB openDb() - Unknown error.")
        }
    }
    
    private func createTable() {
        do {
            try db.createTable(table: MagnetRecord.self)
        } catch {
            print("MagnetDB createTable() - Create table unsuccessful:"+db.errorMessage)
        }
    }
    
    func insert(kValue: String, psValue: Double) {
        do {
            try db.insertMagnet(magnet: MagnetRecord(key: kValue, physicalSize: psValue))
        } catch {
          print("MagnetDB insert() - "+db.errorMessage)
        }
    }
    
    func all() -> Array<MagnetRecord> {
        do {
            let results = try db.all()
            return results
        } catch {
            print("MagnetDB all() - "+db.errorMessage)
        }
    }
    
    func exists(key: String) -> Bool {
        do {
            let result = try db.exists(key: key)
            return result
        } catch {
            print("MagnetDB exists() - "+db.errorMessage)
        }
        return false
    }
}

//class MagnetDB {
//
//    static let shared = MagnetDB()
//
//    var db:Connection? = nil
//    let id = Expression<Int64>("id")
//    let key = Expression<String>("key")
//    let physicalSize = Expression<Double>("physicalSize")
//    let magnets = Table("magnet")
//
//    init(){}
//
//    func configure() {
//        self.openDb()
//        self.createTable()
//    }
//
//    private func openDb() {
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//            ).first!
//
//        do {
//            db = try Connection("\(path)/Magnets.sqlite3")
//        } catch {
//            print("MagnetDB - Connection unsuccessful.")
//        }
//    }
//
//    private func createTable() {
//        guard let db = self.db else { return }
//        do {
//            try db.run(magnets.create(ifNotExists: true) { t in
//                t.column(id, primaryKey: .autoincrement)
//                t.column(key, unique: true)
//                t.column(physicalSize)
//            })
//        } catch {
//            print("MagnetDB - Create table unsuccessful.")
//        }
//    }
//
//   func insert(kValue: String, psValue: Double) {
//        guard let db = self.db else { return }
//        let magnets = Table("magnet")
//        do {
//            let rowid = try db.run(magnets.insert(key <- kValue, physicalSize <- psValue))
//            print("MagnetDB - Inserted \(rowid)")
//        } catch {
//            print("MagnetDB - Insert failed")
//        }
//    }
//
//    func all() -> Array<MagnetRecord> {
//        var allMagnets = Array<MagnetRecord>()
//        guard let db = self.db else { return [] }
//        do {
//        for magnet in try db.prepare(magnets) {
//            do {
//                let magnet = MagnetRecord(key: try magnet.get(key), physicalSize: try magnet.get(physicalSize))
//                allMagnets.append(magnet)
//            } catch {
//                print("MagnetDB - Fetching all magnets fail")
//            }
//        }
//        } catch {
//            print("MagnetDB - No database")
//        }
//        return allMagnets
//    }
//
//    func get(_ withKey: String) -> Row? {
//        guard let db = self.db else { return nil }
//        do {
//            let magnet = magnets.filter(key == withKey)
//            let row = try db.pluck(magnet)
//            return row
//        } catch {
//            return nil
//        }
//    }
//
//    func exists(withKey: String) -> Bool {
//        return (nil != get(withKey))
//    }
//}



//import UIKit
//import SQLite
//
//class MagnetDB {
//
//    static let shared = MagnetDB()
//    
//    var db:Connection? = nil
//    let id = Expression<Int64>("id")
//    let key = Expression<String>("key")
//    let physicalSize = Expression<Double>("physicalSize")
//    let magnets = Table("magnet")
//    
//    init(){}
//    
//    func configure() {
//        self.openDb()
//        self.createTable()
//    }
//    
//    private func openDb() {
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//            ).first!
//        
//        do {
//            db = try Connection("\(path)/Magnets.sqlite3")
//        } catch {
//            print("MagnetDB - Connection unsuccessful.")
//        }
//    }
//    
//    private func createTable() {
//        guard let db = self.db else { return }
//        do {
//            try db.run(magnets.create(ifNotExists: true) { t in
//                t.column(id, primaryKey: .autoincrement)
//                t.column(key, unique: true)
//                t.column(physicalSize)
//            })
//        } catch {
//            print("MagnetDB - Create table unsuccessful.")
//        }
//    }
//    
//   func insert(kValue: String, psValue: Double) {
//        guard let db = self.db else { return }
//        let magnets = Table("magnet")
//        do {
//            let rowid = try db.run(magnets.insert(key <- kValue, physicalSize <- psValue))
//            print("MagnetDB - Inserted \(rowid)")
//        } catch {
//            print("MagnetDB - Insert failed")
//        }
//    }
//    
//    func all() -> Array<MagnetRecord> {
//        var allMagnets = Array<MagnetRecord>()
//        guard let db = self.db else { return [] }
//        do {
//        for magnet in try db.prepare(magnets) {
//            do {
//                let magnet = MagnetRecord(key: try magnet.get(key), physicalSize: try magnet.get(physicalSize))
//                allMagnets.append(magnet)
//            } catch {
//                print("MagnetDB - Fetching all magnets fail")
//            }
//        }
//        } catch {
//            print("MagnetDB - No database")
//        }
//        return allMagnets
//    }
//    
//    func get(_ withKey: String) -> Row? {
//        guard let db = self.db else { return nil }
//        do {
//            let magnet = magnets.filter(key == withKey)
//            let row = try db.pluck(magnet)
//            return row
//        } catch {
//            return nil
//        }
//    }
//    
//    func exists(withKey: String) -> Bool {
//        return (nil != get(withKey))
//    }
//}

