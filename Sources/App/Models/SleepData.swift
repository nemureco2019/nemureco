//
//  SleepData.swift
//  App
//
//  Created by 本田悠隼 on 2019/06/11.
//

import Vapor
import Foundation
import FluentPostgreSQL


final class SleepData:Codable,Content,PostgreSQLUUIDModel,Parameter {
    var id: UUID?
    var weakUP:Date
    var sleep:Date
    var userID:User.ID
    var stamp:String //データを送信した日時
    //2019/06/30
    var dayTime:String //日
    var month:String //月
    var week:String //曜日
    var carender:String //検索文字列
    //確認項目
    var alarm:String
    var shit:String
    var breakfast:String
    //追加項目　2019/06/25
    var sick:String //発熱
    var nose:String //鼻水
    var cough:String //咳
    var hurt:String //怪我
    var vomiting:String  //嘔吐
    var diarrhea:String //下痢
    var constipation:String //便秘
    var snore:String //いびき
    var other:String //その他
    //さらに追加
    var cryData:String

    //CSV専用起床/入眠
    var weakUP2:String
    var sleep2:String
    //グラフ描画
    var weak3:String
    var sleep3:String
    
    //追加項目
    var year:String
    var comment:String
    //CSVの為に追加
    var csv:String
  
    init(
        weakUP:Date,sleep:Date,userID:User.ID,stamp:String,dayTime:String,month:String,week:String,carender:String,
        alarm:String,shit:String,breakfast:String,weakUP2:String,
        sleep2:String,sick:String,nose:String,
        cough:String,hurt:String,vomiting:String,
        diarrhea:String,constipation:String,
        snore:String,other:String,year:String,cryData:String,weak3:String,sleep3:String,csv:String,comment:String) {
        self.userID = userID
        self.weakUP = weakUP
        self.dayTime = dayTime
        self.month = month
        self.week = week
        self.carender = carender
        self.sleep = sleep
        self.alarm = alarm
        self.shit = shit
        self.breakfast = breakfast
        //自動作成
        self.weakUP2 = weakUP2
        self.sleep2 = sleep2
        self.stamp = stamp
        //追加　2019/06/25
        self.sick = sick
        self.nose = nose
        self.cough = cough
        self.hurt = hurt
        self.vomiting = vomiting
        self.diarrhea = diarrhea
        self.constipation = constipation
        self.snore = snore
        self.other = other
        //2019/06/25
        self.year = year
        //2019/06/28
        self.cryData = cryData
        self.weak3 = weak3
        self.sleep3 = sleep3
        //2019/07/01
        self.csv = csv
        self.comment = comment
   
    }
    
    final class Public:Codable,Content{
        var id: UUID?
        var userID:User.ID
        var weakUP:Date   //UNIXTime
        var sleep:Date    //UNIXTime
        //確認項目
        var alarm:String
        var shit:String
        var breakfast:String
        //追加項目　2019/06/25
        var sick:String //発熱
        var nose:String //鼻水
        var cough:String //咳
        var hurt:String //怪我
        var vomiting:String  //嘔吐
        var diarrhea:String //下痢
        var constipation:String //便秘
        var snore:String //いびき
        var other:String //その他
        var cryData:String
        var comment:String
        //追加項目
        var year:String
         init(userID:User.ID,weakUP:Date,sleep:Date,
              stamp:String,alarm:String,shit:String,breakfast:String,sick:String,nose:String,cough:String,hurt:String,vomiting:String,diarrhea:String,constipation:String,snore:String,other:String,year:String,cryData:String,comment:String) {
            self.userID = userID
            self.weakUP = weakUP
            self.sleep = sleep
            self.alarm = alarm
            self.shit = shit
            self.breakfast = breakfast
            //追加　2019/06/25
            self.sick = sick
            self.nose = nose
            self.cough = cough
            self.hurt = hurt
            self.vomiting = vomiting
            self.diarrhea = diarrhea
            self.constipation = constipation
            self.snore = snore
            self.other = other
            //2019/06/25
            self.year = year
            self.cryData = cryData
            self.comment = comment
        }
        
    }
}

//PostgreModel:Migrations
extension SleepData:Migration {
    static func prepare(on connection:PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection){ builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to:\User.id )
        }
    }
}

//nemurecoUserと親子関係
extension SleepData {
    var user:Parent<SleepData,User>{
        return parent(\.userID)
    }
    
    func convertToPublic() -> SleepData.Public {
        return SleepData.Public(userID: userID, weakUP: weakUP, sleep: sleep, stamp: stamp, alarm: alarm, shit: shit, breakfast: breakfast, sick: sick, nose: nose, cough: cough, hurt: hurt, vomiting: vomiting, diarrhea: diarrhea, constipation: constipation, snore: snore, other: other, year: year,cryData: cryData,comment: comment)
    }
}

extension Future where T:SleepData{
    func convertToPublic() -> Future<SleepData.Public> {
        return self.map(to: SleepData.Public.self){ sleepData in
            return sleepData.convertToPublic()
        }
    }
}
