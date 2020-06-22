//
//  Database.swift
//  Dr-Soldier
//
//  Created by leejungjae on 2020/05/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import Foundation
import SQLite3

class DataBaseQuery {
    
    let CreateUserTable = """
    CREATE TABLE "User" (
    "email"   TEXT NOT NULL,
    "name"    TEXT NOT NULL,
    "grade"    INTEGER ,
    "start_date"    TEXT ,
    "end_date"    TEXT ,
    "image_url"    TEXT
    );
    """
    
    let CreateTodoTable = """
    CREATE TABLE "Todo" (
        "goal"    TEXT NOT NULL,
        "completed"    INTEGER NOT NULL DEFAULT 0
    );
    """
    
    let CreateRecordTable = """
    CREATE TABLE "Record" (
        "checked_date"    TEXT NOT NULL,
        "height"    REAL,
        "weight"    REAL
    );
    """
    
    let CreateFitnessTable = """
    CREATE TABLE "Fitness" (
        "checked_date"    TEXT NOT NULL,
        "pushup"    INTEGER,
        "situp"    INTEGER,
        "runMinute"    INTEGER,
        "runSecond"    INTEGER,
        "pk"           INTEGER
    );
    """
    
    
    
    let CreateCalenderTable = """
    CREATE TABLE "Calendar" (
    "marked_date"    TEXT NOT NULL,
    "type"    INTEGER NOT NULL
    );
    """
    
    let CreateLevelTable = """
    CREATE TABLE "Level" (
    "level" INTEGER NOT NULL DEFAULT 0
    );
    """
    
    
    public func SelectStar(Tablename:String) ->String{
        return "SELECT * FROM " + Tablename + ";"
    }
    
    public func Delete(Tablename: String , Condition : String) -> String{
        return "DELETE FROM " + Tablename + " WHERE " + Condition + ";"
    }
    
    public func insert(Tablename: String , Values : String) -> String{
        return "INSERT INTO " + Tablename + " VALUES " + "(" + Values + ")" + ";"
    }
    
    public func update(Tablename: String, beforeValues : String, afterValues : String) -> String{
        return "UPDATE " + Tablename + " SET " + afterValues + " WHERE " + beforeValues + ";"
    }
}


class DataBaseAPI {
    
    var database : OpaquePointer? = nil
    var Query : DataBaseQuery
    
    public init()
    {
        let fileURL1 = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) .appendingPathComponent("db.sqlite")
        //let fileURL2 = Bundle.main.url(forResource: "LocalDB_SQLite", withExtension: "db")?.absoluteString as! String
        sqlite3_open(fileURL1.path,&self.database)
        Query = DataBaseQuery.init()
    }
    
    public func createTable(statement : String) -> Bool{
        var createStatement : OpaquePointer? = nil
        defer { sqlite3_finalize(createStatement) }
        guard sqlite3_prepare_v2(self.database,statement,EOF,&createStatement,nil) == SQLITE_OK else{
            print("Fail to prepare create table")
            return false
        }
        if sqlite3_step(createStatement) == SQLITE_DONE{
            print("Success to create table")
        }else{
            print("!! Fail, Contact table could not be created.")
        }
        return true
    }
    
    public func CreateEveryTable(){
        var tmp : Bool = true
        tmp = self.createTable(statement: Query.CreateUserTable)
        tmp = self.createTable(statement: Query.CreateTodoTable)
        tmp = self.createTable(statement: Query.CreateCalenderTable)
        tmp = self.createTable(statement: Query.CreateRecordTable)
        tmp = self.createTable(statement: Query.CreateFitnessTable)
        tmp = self.createTable(statement: Query.CreateLevelTable)
        print(tmp)
        print("모든 테이블 생성 성공!")
    }
    
    //insert
    public func insert(statement : String) -> Bool {
        var insertStatement : OpaquePointer? = nil
        defer { sqlite3_finalize(insertStatement) }
        guard sqlite3_prepare_v2(self.database,statement,EOF,&insertStatement,nil) == SQLITE_OK else{
            print("Fail to prepare insert to table")
            return false
        }
        if sqlite3_step(insertStatement) == SQLITE_DONE{
           print("Success to insert")
       }else{
           print("Fail to insert")
       }
       return true
    }

    //delete
    public func delete(statement : String) -> Bool {
        var deleteStatement : OpaquePointer? = nil
        defer { sqlite3_finalize(deleteStatement) }
        guard sqlite3_prepare_v2(self.database,statement,EOF,&deleteStatement,nil) == SQLITE_OK else{
            print("Fail to prepare delete to table")
            return false
        }
        if sqlite3_step(deleteStatement) == SQLITE_DONE{
           print("Success to delete")
       }else{
           print("Fail to delete")
       }
       return true
    }
    
    public func update(statement : String) -> Bool {
        var deleteStatement : OpaquePointer? = nil
        defer { sqlite3_finalize(deleteStatement) }
        guard sqlite3_prepare_v2(self.database,statement,EOF,&deleteStatement,nil) == SQLITE_OK else{
            print("Fail to prepare update to table")
            return false
        }
        if sqlite3_step(deleteStatement) == SQLITE_DONE{
           print("Success to update")
       }else{
           print("Fail to update")
       }
       return true
    }
    
    //select
    public func query(statement : String, ColumnNumber: Int) -> Array<Array<String>> {
        var queryStatement: OpaquePointer?
        var TotalResultTable : Array<Array<String>> = []
        if sqlite3_prepare_v2(self.database, statement, -1, &queryStatement, nil) == SQLITE_OK
        {
            var each_row : Array<String> = []
            
            //한줄씩 읽어드린다.
            while sqlite3_step(queryStatement) == SQLITE_ROW
            {
                //왼쪽부터 오른쪽으로 읽어드린다.
                for i in 0 ... (ColumnNumber-1){
                    if let each_cell = sqlite3_column_text(queryStatement,Int32(i)){
                         each_row.append(String(cString : each_cell ))
                    }
                    //print( String(cString : each_cell! ))
                    //string으로 형변환
                }
                TotalResultTable.append(each_row)
                each_row.removeAll()
            }
        }
        else
        {
            let errorMessage = String(cString: sqlite3_errmsg(self.database))
            print("Query is not prepared \(errorMessage)\n")
        }
          sqlite3_finalize(queryStatement)
          return TotalResultTable
    }
}
