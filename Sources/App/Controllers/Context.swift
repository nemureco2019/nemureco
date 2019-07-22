//
//  Context.swift
//  App
//
//  Created by 本田悠隼 on 2019/05/28.
//


import Vapor
import Foundation
import Authentication
import FluentSQL

//Emfitの編集
struct EmfitData:Content,Encodable,Decodable {
    var emfitId:String
    var emfitLastDate:String
}


//睡眠データの塊
struct  SleepDataSearcher:Content,Encodable,Decodable{
    var sleepData:[SleepData]
}

struct AllUserContext:Content,Encodable,Decodable {
    var user:[User]
}

struct LoginContext: Encodable {
    let title = "Log In"
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

struct RegisterContext: Encodable {
    let title = "make new user"
    var registrationError = false
}

struct RegisterData: Content {
    let name: String
    let username: String
    let password: String
    let confirmPassword: String
    var birthday:String
    var comment:String
    var gender:String
    var height:String
    var nickname:String
    var weight:String  //体重
}

struct updateUserdata:Content,Encodable,Decodable{
    let name: String
    let username: String
    let password:String
    var birthday:String
    var comment:String
    var gender:String
    var height:String
    var nickname:String
    var weight:String  //体重
  
}

struct EmfitUserID:Content,Encodable,Decodable {
    //2019/7/20
    var EmfitDeviceID:String
    var emfitLastDate:String
}

//Client

struct UserClientContext:Content {
    var name:String?
    var username:String?
    var id:String?
    var password:String?
}

//Menu
struct menuContext:Encodable {
    var user:User
}


//Genre
struct postGenreContext:Content,Encodable,Decodable{
    var name:String
}

struct genreContext:Content,Encodable,Decodable{
    var title:String
    var word:String
}

//SleepDataの作成
struct sleepDataContext:Content,Encodable,Decodable {
    var id: UUID?
    var weakUP:Date
    var sleep:Date
    //確認項目
    var alarm:String
    var shit:String
    var breakfast:String
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
}

//SleepDataのupDate
struct sleepDataUpdateContext:Content,Encodable,Decodable{
    var weakUP:Date
    var sleep:Date
    //確認項目
    var alarm:String
    var shit:String
    var breakfast:String
    //2019/06/30追加
    var sick:String //発熱
    var nose:String //鼻水
    var cough:String //咳
    var hurt:String //怪我
    var vomiting:String  //嘔吐
    var diarrhea:String //下痢
    var constipation:String //便秘
    var snore:String //いびき
    var other:String //その他
/*    var stamp:String //データを送信した日時
    //視認できる起床/入眠
    var weakUP2:String
    var sleep2:String
 */
    //2019/06/28
    var cryData:String
    var comment:String
 
    
}

//View Sleep Data
struct  usersSleepdataContext:Content,Encodable,Decodable{
    var user:User
    var sleepData:[SleepData]
    var users:[User]
}


