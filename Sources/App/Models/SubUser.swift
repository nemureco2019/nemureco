//
//  SubUser.swift
//  App
//
//  Created by 本田悠隼 on 2019/07/05.
//

import Foundation
import FluentPostgreSQL
import Authentication
import Vapor

final class SubUser:Codable,Content,PostgreSQLUUIDModel,Parameter{
    
    var id: UUID?
    var name:String
    var userID:User.ID
    var username:String
    var password:String
    var birthday:String
    var comment:String
    var gender:String
    var height:String
    var nickname:String
    var weight:String  //体重
    var firstDate:String
    var dayTime:String //日
    var month:String //月
    //2019/7/20
    var EmfitDeviceID:String
    var emfitLastDate:String
    
    init(name:String,userID:User.ID,password:String,birthday:String,comment:String,
         
         gender:String,height:String,nickname:String,dayTime:String,month:String,
         weight:String,username:String,firstDate:String,EmfitDeviceID:String
        ,emfitLastDate:String) {
        self.username = username
        self.name = name
        self.userID = userID
        //追加要素
        self.password = password
        self.birthday = birthday
        self.comment = comment
        self.gender = gender  //性別
        self.height = height  //身長
        self.nickname = nickname
        self.weight = weight  //体重
        self.firstDate = firstDate
        self.dayTime = dayTime
        self.month = month
        self.EmfitDeviceID = EmfitDeviceID
        self.emfitLastDate = emfitLastDate
    }
    
    }

//PostgreModel:Migrations
extension SubUser:Migration {
    static func prepare(on connection:PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to:\User.id )
        }
    }
}

//nemurecoUserと親子関係
extension SubUser {
    var user:Parent<SubUser,User>{
        return parent(\.userID)
    }
    
}

