
import Foundation
import Authentication
import FluentPostgreSQL
import Vapor

final class Token:Codable,PostgreSQLUUIDModel,Content{
    var id:UUID?
    var token:String
    var userID:User.ID
    
    init(token:String,userID:User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token:Migration{
    static func prepare(on connection:PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token {
    static func generate(for user:User) throws -> Token{
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token:BearerAuthenticatable {
    static let tokenKey:TokenKey = \Token.token
}

extension Token:Authentication.Token{
    typealias UserType = User
    static let userIDKey:UserIDKey = \Token.userID
}

//Userと親子関係
extension Token{
    var user:Parent<Token,User>{
        return parent(\.userID)
    }
}
