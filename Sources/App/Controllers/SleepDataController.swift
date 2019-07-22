//
//  SleepDataController.swift
//  App
//
//  Created by 本田悠隼 on 2019/06/11.
//

import Foundation
import Vapor
import Authentication
import FluentPostgreSQL

struct SleepDataController:RouteCollection {
    func boot(router: Router) throws {
        let sleetDataRoute = router.grouped("api/sleep")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = sleetDataRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //SleepDataの作成
        tokenAuthGroup.post(sleepDataContext.self, use: makeSleepDataHandler)
        //すべてのデータ
        tokenAuthGroup.get("alldata", use: allSleepDataViewer)
        //Userが作成したデータ
        tokenAuthGroup.get("data",User.parameter, use: usersSleepDataViewer)
        //データの消去
        tokenAuthGroup.delete("delete",SleepData.parameter, use: sleepDataDeleteHandler)
        //データのアップデート
        tokenAuthGroup.put("update",SleepData.parameter, use: updateSleepDataHandler)
       
    }
    
    
    
    //データの編集
    func updateSleepDataHandler(_ req:Request) throws -> Future<SleepData>{
        return try flatMap(to:SleepData.self, req.parameters.next(SleepData.self), req.content.decode(sleepDataUpdateContext.self)){ sleepData,updateSleepData in
            //タイムスタンプの作成
            let dateformatter = DateFormatter()
            dateformatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            dateformatter.dateFormat = "yyyy,MM,dd,HH,mm,0"
            //作成日時
            let value = dateformatter.string(from:Date())
            //検索の為のスタンプ作成(年/月)
            let yearDateformatter = DateFormatter()
            yearDateformatter.timeZone =  TimeZone(identifier: "Asia/Tokyo")
            yearDateformatter.dateFormat =  "yyyy"
            //入眠時の年
            let year = yearDateformatter.string(from: updateSleepData.sleep)
            //月(MM)
            let monthData = DateFormatter()
            monthData.timeZone =   TimeZone(identifier: "Asia/Tokyo")
            monthData.dateFormat = "MM"
            //月
            let month = monthData.string(from:updateSleepData.sleep)
            let weakMonth =  monthData.string(from: updateSleepData.weakUP)
            //日付の日(日/CSV)
            let dayDateformatter = DateFormatter()
            dayDateformatter.timeZone =  TimeZone(identifier: "Asia/Tokyo")
            dayDateformatter.locale = Locale(identifier: "ja_JP")
            dayDateformatter.dateFormat = "dd"
            //**日
            let day = dayDateformatter.string(from:updateSleepData.sleep)
            //曜日の設定
            let weekFormatter =  DateFormatter()
            weekFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            weekFormatter.dateFormat = "EEE"
            //曜日
            let week = weekFormatter.string(from: updateSleepData.sleep)
            let weakWeek = weekFormatter.string(from: updateSleepData.weakUP)
            
            //新規データ
            sleepData.weakUP = updateSleepData.weakUP
            sleepData.sleep = updateSleepData.sleep
            //睡眠時のデータ形式(HH:MM)
            let sleepTime = DateFormatter()
            sleepTime.timeZone =  TimeZone(identifier: "Asia/Tokyo")
            sleepTime.dateFormat = "HHmm"
            //起床
            let valueWeakUP = sleepTime.string(from:updateSleepData.weakUP)
            //入眠
            let sleepValue = sleepTime.string(from:updateSleepData.sleep)
            //検索文字列
            let carender = DateFormatter()
            carender.timeZone = TimeZone(identifier: "Asia/Tokyo")
            carender.dateFormat = "yyyyMM"
            let sleepday = dayDateformatter.string(from:updateSleepData.sleep)
            let weakDay = dayDateformatter.string(from: updateSleepData.weakUP)
            
            //検索日時
            let carenderValue = carender.string(from:updateSleepData.sleep)
        
            //日付処理
            var breakFast = sleepData.breakfast
            var alarm = sleepData.alarm
            var shit = sleepData.shit
            
            //差分計算
            var dayDiff:String =  "0"
            if (sleepday.compare(weakDay)  == .orderedAscending)  {
                //Weakが後
                dayDiff = "0"
            } else if (sleepday.compare(weakDay)  == .orderedSame)  {
                //同じ日
                //同じ日
                dayDiff = "1"  ;breakFast = "-";alarm = "-";shit = "-"
                
            }   else if (sleepday.compare(weakDay)  == .orderedDescending) {
                //weakが前
                dayDiff = "error"
            }
        
            sleepData.weakUP = updateSleepData.weakUP //起床
            sleepData.sleep = updateSleepData.sleep //入眠
            sleepData.alarm = alarm
            sleepData.shit = shit
            sleepData.breakfast = breakFast
            sleepData.sick = updateSleepData.sick
            sleepData.nose = updateSleepData.nose
            sleepData.cough = updateSleepData.cough
            sleepData.hurt = updateSleepData.hurt
            sleepData.vomiting = updateSleepData.vomiting
            sleepData.diarrhea = updateSleepData.diarrhea
            sleepData.constipation = updateSleepData.constipation
            sleepData.snore = updateSleepData.snore
            sleepData.other = updateSleepData.other
            sleepData.stamp = value  //作成日時
            sleepData.weakUP2 = valueWeakUP
            sleepData.sleep2 = sleepValue
            sleepData.year = year  //年
            //2019/06/30追加
            sleepData.month = month  //月
            sleepData.dayTime = day  //日
            sleepData.cryData = updateSleepData.cryData
            sleepData.comment = updateSleepData.comment
            //2019/07/02追加
            sleepData.carender = carenderValue // 年月
            sleepData.week = week //曜日
            
            //文字列で解決
            let Comment0:String = updateSleepData.sick + "," + updateSleepData.nose + "," +
                updateSleepData.cough + "," + updateSleepData.hurt + "," + updateSleepData.vomiting + "," + updateSleepData.diarrhea + "," + updateSleepData.constipation + "," + updateSleepData.snore + "," + updateSleepData.other
            
            //グラフ描画
            let weak3:String =  "" + "," + weakMonth + "," + weakDay + "," + weakWeek + "," + "0" +  ","  + updateSleepData.breakfast + "," + updateSleepData.alarm + "," + updateSleepData.shit + "," + Comment0
                
                + "," + updateSleepData.cryData + "," + updateSleepData.comment + "," + "" + "," + "" + "," + "0" + "," + dayDiff + "," + valueWeakUP + ","
            
            sleepData.weak3 = weak3 //グラフ用
            sleepData.sleep3 = dayDiff //グラフ用
        
            //CSV
            sleepData.csv =  month + "," + day + "," + week + "," + "0" +  "," + breakFast + "," + alarm + "," + shit
                + ","  + Comment0
                + "," + updateSleepData.cryData + "," + updateSleepData.comment + "," + "" + "," + "" + "," + "0" + "," + "1,\(sleepValue)," +  "0,\(valueWeakUP)" + ","
 
            return sleepData.save(on: req)
        }
    }
    
    //データの消去
    func  sleepDataDeleteHandler(_ req:Request) throws -> Future<HTTPStatus>{
    return try req.parameters.next(SleepData.self).delete(on: req).transform(to:.noContent )
    }
    
   
    //データの作成
    func makeSleepDataHandler(_ req:Request,data:sleepDataContext) throws -> Future<SleepData>{
        //タイムスタンプの作成
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateformatter.dateFormat = "yyyy,MM,dd,HH,mm,0"

        //検索の為のスタンプ作成(年/CSV)
        let yearDateformatter = DateFormatter()
        yearDateformatter.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        yearDateformatter.dateFormat =  "yyyy"
        //検索文字列
        let carender = DateFormatter()
        carender.timeZone = TimeZone(identifier: "Asia/Tokyo")
        carender.dateFormat = "yyyyMM"
        //月
        let monthData = DateFormatter()
        monthData.timeZone =   TimeZone(identifier: "Asia/Tokyo")
        monthData.dateFormat = "MM"
        //曜日の設定
        let weekFormatter =  DateFormatter()
        weekFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        weekFormatter.dateFormat = "EEE"
        
        //日付の日(日/CSV)
        let dayDateformatter = DateFormatter()
        dayDateformatter.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        dayDateformatter.locale = Locale(identifier: "ja_JP")
        dayDateformatter.dateFormat = "dd"
        //睡眠時のデータ形式
        let sleepTime = DateFormatter()
        sleepTime.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        sleepTime.dateFormat = "HHmm"
        //起床時のデータの形式
        let weakTime = DateFormatter()
        weakTime.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        weakTime.dateFormat = "HHmm"
     
        //作成日時
        let value = dateformatter.string(from:Date())
        //**日
        let sleepday = dayDateformatter.string(from:data.sleep)
        let weakDay = dayDateformatter.string(from: data.weakUP)
        //月
        let sleepMonth = monthData.string(from:data.sleep)
        let weakMonth = monthData.string(from: data.weakUP)
        //検索
        let sleepCarenderString = carender.string(from:data.sleep)
        //曜日
        let sleepWeek = weekFormatter.string(from:data.sleep)
        let weakWeek = weekFormatter.string(from: data.weakUP)
        
        //2019/07/14
        //起床
        let valueWeakUP = weakTime.string(from:data.weakUP)
        //入眠
        let sleepValue = sleepTime.string(from:data.sleep)
    
        //日付処理
        var breakFast = data.breakfast
        var alarm = data.alarm
        var shit = data.shit
        
        //差分計算
        var dayDiff:String =  "0"
        if (sleepday.compare(weakDay)  == .orderedAscending)  {
            //Weakが後
            dayDiff = "0"
        } else if (sleepday.compare(weakDay)  == .orderedSame)  {
            //同じ日
            dayDiff = "1";breakFast = "-";alarm = "-";shit = "-"
        }   else if (sleepday.compare(weakDay)  == .orderedDescending) {
           //weakが前
            dayDiff = "error"
        }
        //作成年月
        let  yearValue = yearDateformatter.string(from:data.sleep)
        
        let user = try req.requireAuthenticated(User.self)
        let userID = try user.requireID()
        
        //文字列で解決 "" + ","
        let Comment0:String =  data.sick  + data.nose  + data.cough +  data.hurt +  data.vomiting +  data.diarrhea  + data.constipation +  data.snore + data.other
        
        //文字列
        let CSV:String = "" + "," + sleepMonth + "," + sleepday + "," + sleepWeek + "," + "0" +  "," + "" + "," + "" + "," + "" + ","
            
            + "," + "" + "," + "" + "," + "" + "," + "" + "," + "0" + "," + "1" + "," + sleepValue + "," + "\(userID)"
        //weak3 = CSV2  //sleep3 = dayDiff
        let weak3:String =  "" + "," + weakMonth + "," + weakDay + "," + weakWeek + "," + "0" +  ","  + breakFast + "," + alarm + "," + shit + "," + Comment0
            
            + "," + data.cryData + "," + data.comment + "," + "" + "," + "" + "," + "0" + "," + dayDiff + "," + valueWeakUP + "," + "\(userID)"

        
        let postData = try SleepData(weakUP:data.weakUP, sleep: data.sleep, userID: user.requireID(), stamp: value,
                                     dayTime: sleepday,month:sleepMonth,week:sleepWeek,carender:sleepCarenderString,
                                     alarm: data.alarm, shit: data.shit, breakfast: data.breakfast,
                                     weakUP2: valueWeakUP, sleep2: sleepValue,
                                     sick: data.sick, nose: data.nose, cough: data.cough, hurt: data.hurt, vomiting: data.vomiting, diarrhea: data.diarrhea, constipation: data.constipation, snore: data.snore, other: data.other, year: yearValue, cryData: data.cryData,weak3:weak3,sleep3:dayDiff,
                //ここからCSV
    csv:CSV,
    comment:data.comment
        )
        
        return postData.save(on: req)
    }

    //データの一覧
    func allSleepDataViewer(_ req:Request) throws -> Future<[SleepData]>{
        return SleepData.query(on: req).all()
    }
    //ユーザーの作成したデータ
    func usersSleepDataViewer(_ req:Request) throws -> Future<[SleepData]>{
        return try req.parameters.next(User.self).flatMap(to:[SleepData].self){
            user in
       try  user.sleepData.query(on: req).all()
        }
    }
    
    
}
