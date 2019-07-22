//

import Foundation
import FluentPostgreSQL
import Authentication
import Vapor

final class User:Codable,Content,PostgreSQLUUIDModel,Parameter,PasswordAuthenticatable,SessionAuthenticatable{
    //管理用
    var id:UUID?
    var name:String
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
    
    init(name:String,username:String,password:String,birthday:String,comment:String,
         
         gender:String,height:String,nickname:String,dayTime:String,month:String,
         weight:String,firstDate:String,EmfitDeviceID:String
    ,emfitLastDate:String) {
        self.name = name
        self.username = username
        self.password = password
        //追加要素
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
    //他の人に見られても問題無いデータを表示させる
    final class Public:Codable,Content{
        var id:UUID?
        var name:String
        var username:String
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
        
        init(id:UUID?,name:String,username:String,birthday:String,comment:String,
             
             gender:String,height:String,nickname:String,dayTime:String,month:String,
             weight:String,firstDate:String,EmfitDeviceID:String
            ,emfitLastDate:String) {
            self.id = id
            self.name = name
            self.username = username
            //追加要素
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
}

extension User:Migration {
    static func prepare(on connection:PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

//パスワードだけならいらない
extension User:BasicAuthenticatable{
    static let usernameKey:UsernameKey = \User.username
    static let passwordKey:PasswordKey = \User.password
}

extension User{
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username,
                           birthday: birthday,comment: comment,gender: gender,
                           height: height,nickname:nickname,
                           dayTime: dayTime,month:month,
                           weight:weight,firstDate:firstDate,EmfitDeviceID: EmfitDeviceID,emfitLastDate: emfitLastDate
        )
    }
}

extension Future where T:User{
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self){ user in
            return user.convertToPublic()
        }
    }
}

//Token対応のために拡張
extension User:TokenAuthenticatable{
    typealias TokenType  = Token
}


extension User {
    var sleepData:Children<User,SleepData>{
            return children(\.userID)
   }
    
    var subUser:Children<User,SubUser>{
        return children(\.userID)
    }
   
    var emfit:Children<User,Emfit>{
        return children(\.userID)
    }
}
