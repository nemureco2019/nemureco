//
//  Emfit.swift
//  App
//
//  Created by 本田悠隼 on 2019/07/05.
//

import Foundation
import FluentPostgreSQL
import Authentication
import Vapor

final class Emfit:Codable,Content,PostgreSQLUUIDModel,Parameter{
    var id: UUID?
    var emfitId:String
    var emfitLastDate:String
    var userID:User.ID

    init(emfitId:String,userID:User.ID,emfitLastDate:String) {
        self.emfitId = emfitId
        self.userID = userID
        self.emfitLastDate = emfitLastDate
    }
}

//PostgreModel:Migrations
extension Emfit:Migration {
    static func prepare(on connection:PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to:\User.id )
        }
    }
}

//nemurecoUserと親子関係
extension Emfit {
    var emfit:Parent<Emfit,User>{
        return parent(\.userID)
    }
}
