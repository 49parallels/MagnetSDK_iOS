//
//  SQLiteDatabase.swift
//  MagnetSDK
//
//  Created by e.d.neutrum on 10/11/2019.
//  Copyright © 2019 e.d.neutrum. All rights reserved.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
  case OpenDatabase(message: String)
  case Prepare(message: String)
  case Step(message: String)
  case Bind(message: String)
}

protocol SQLTable {
  static var createStatement: String { get }
}

class SQLiteDatabase {
    
    fileprivate let dbPointer: OpaquePointer?

    fileprivate init(dbPointer: OpaquePointer?) {
      self.dbPointer = dbPointer
    }
    
    var errorMessage: String {
      if let errorPointer = sqlite3_errmsg(dbPointer) {
        let errorMessage = String(cString: errorPointer)
        return errorMessage
      } else {
        return "No error message provided from sqlite."
      }
    }

    deinit {
      sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
      var db: OpaquePointer? = nil
      // 1
      if sqlite3_open(path, &db) == SQLITE_OK {
        // 2
        return SQLiteDatabase(dbPointer: db)
      } else {
        // 3
        defer {
          if db != nil {
            sqlite3_close(db)
          }
        }

        if let errorPointer = sqlite3_errmsg(db) {
          let message = String.init(cString: errorPointer)
          throw SQLiteError.OpenDatabase(message: message)
        } else {
          throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
        }
      }
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
      var statement: OpaquePointer? = nil
      guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
        throw SQLiteError.Prepare(message: errorMessage)
      }

      return statement
    }
    
    func createTable(table: SQLTable.Type) throws {
      // 1
      let createTableStatement = try prepareStatement(sql: table.createStatement)
      // 2
      defer {
        sqlite3_finalize(createTableStatement)
      }
      // 3
      guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
        throw SQLiteError.Step(message: errorMessage)
      }
      print("\(table) table created.")
    }
    
    func insertMagnet(magnet: MagnetRecord) throws {
        let insertSql = "INSERT INTO Magnet (key, physicalSize) VALUES (?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
      
        defer {
            sqlite3_finalize(insertStatement)
        }

        let key:NSString = magnet.key as NSString
        
        guard sqlite3_bind_text(insertStatement, 1, key.utf8String, -1, nil) == SQLITE_OK && sqlite3_bind_double(insertStatement, 2, magnet.physicalSize) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
          throw SQLiteError.Step(message: errorMessage)
        }

        print("Successfully inserted row.")
    }
    
    func all() -> Array<MagnetRecord> {
        var results = Array<MagnetRecord>();
        let querySql = "SELECT * FROM Magnet"
        do {
            let queryStatement = try prepareStatement(sql: querySql)
            
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                //let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let key = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_double(queryStatement, 2)
                let physicalSize = Double(queryResultCol2)
                
                results.append(MagnetRecord(key: key, physicalSize: physicalSize))
            }
        } catch {
            print("Error reading table Magnet")
        }
        return results
    }
    
    func exists(key: String) -> Bool {
        let checkSql = "SELECT * FROM Magnet WHERE key = ?;"
        do {
            let queryStatement = try prepareStatement(sql: checkSql)
            
            guard sqlite3_bind_text(queryStatement, 1, key, -1, nil) == SQLITE_OK else {
              return false
            }

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                return true
            } else {
                return false
            }
        } catch {
            print("Error reading table Magnet")
        }
        return false
    }
    
}
