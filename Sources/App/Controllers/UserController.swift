//
//  UserController.swift
//  App
//
//  Created by 本田悠隼 on 2019/06/11.
//

import Foundation
import Vapor
import Authentication
import FluentPostgreSQL
import Crypto

struct UserController:RouteCollection {
    func boot(router: Router) throws {
        //ユーザー作成
        let userRoute = router.grouped("api","user")
        userRoute.post(User.self, use: createHandler)
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = userRoute.grouped(basicAuthMiddleware)
        //ログイン
        basicAuthGroup.post("login", use: userloginHandler)
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = userRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //ログアウト
        userRoute.post("/logout", use: logoutHandler)
        
        //ユーザー個人の情報
        tokenAuthGroup.get(User.parameter,use:getHandler)
        //ユーザー情報の更新
        tokenAuthGroup.post("update",User.parameter, use: updateUser)
        //ユーザーのEmfit情報の更新
        tokenAuthGroup.post("emfituser",User.parameter, use: addEmfitData)
        
        //サブユーザー
        tokenAuthGroup.post(SubUser.self,at:"subuser", use: makeSubUserHandler)
        //ユーザーの作成したサブユーザーの確認
        tokenAuthGroup.get("subuser",User.parameter, use:subUserView)
        //サブユーザーの更新
        tokenAuthGroup.post("updatesub",SubUser.parameter, use: updateSubUser)
        //サブユーザーのEmfit情報の更新
        tokenAuthGroup.post("subemfit",User.parameter, use:subEmfitUpdate)
        
        //Emfitの作成
        tokenAuthGroup.post(Emfit.self,at:"emfit", use: emfitHandler)
        //Emfit情報の取得
        tokenAuthGroup.get("emfit",User.parameter, use: userEmfitData)
        //Emfit情報の削除
        tokenAuthGroup.delete("emfit","delete",Emfit.parameter, use: deleteEmfit)
        //Emfit情報の更新
        tokenAuthGroup.put("updateemfit",User.parameter, use: updateEmfit)
        
    }
    
    //Emfitのアップデート
    func updateEmfit(_ req:Request) throws -> Future<Emfit>{
        return try flatMap(to:Emfit.self, req.parameters.next(Emfit.self), req.content.decode(EmfitData.self)){ emfit , updateEmfitData in
            emfit.emfitId = updateEmfitData.emfitId
            emfit.emfitLastDate = updateEmfitData.emfitLastDate
            return emfit.save(on:req)
            
        }
    }
    
    //Emfitの削除
    func deleteEmfit(_ req:Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Emfit.self).delete(on: req).transform(to: .noContent)
    }
    
    //ユーザーの作成したEmfit情報
    func userEmfitData(_ req:Request) throws -> Future<[Emfit]>{
        return try req.parameters.next(User.self).flatMap(to:[Emfit].self){ user in
            return try user.emfit.query(on:req).all()
        }
    }
    
    //Emfitの作成
    func emfitHandler(_ req:Request,Emfit:Emfit) throws -> Future<Emfit>{
        return  Emfit.save(on: req)
    }
    
    //ユーザーの作成したサブユーザー
    func subUserView(_ req:Request) throws -> Future<[SubUser]>{
        return try req.parameters.next(User.self).flatMap(to:[SubUser].self){ user in
            return try user.subUser.query(on: req).all()
        }
    }
    
    //SubUserの作成
    func makeSubUserHandler(_ req:Request,subUser:SubUser) throws -> Future<SubUser>{
        //タイムスタンプの作成
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateformatter.dateFormat = "yyyy"
        subUser.firstDate = dateformatter.string(from:Date())
        //月
        let monthDate = DateFormatter()
        monthDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        monthDate.dateFormat = "MM"
        subUser.month = monthDate.string(from:Date())
        //日
        let dayDate = DateFormatter()
        dayDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        dayDate.dateFormat = "dd"
        subUser.dayTime = dayDate.string(from: Date())
        return subUser.save(on: req)
    }
    
    //ユーザーの情報のアップデート
  func  updateUser(_ req:Request) throws -> Future<User>{
    return try flatMap(to:User.self, req.parameters.next(User.self),req.content.decode(updateUserdata.self)){ user ,newUserData in
        user.name = newUserData.name
        user.username = newUserData.username
        user.password = try BCrypt.hash(newUserData.password)
        user.birthday = newUserData.birthday
        user.comment = newUserData.comment
        user.gender = newUserData.gender
        user.height = newUserData.height
        user.weight = newUserData.weight
        user.nickname = newUserData.nickname
      
        return user.save(on: req)
      }
    }
    
    //userのEmfit情報の更新
    func addEmfitData(_ req:Request) throws -> Future<User>{
        return try flatMap(to:User.self, req.parameters.next(User.self),req.content.decode(EmfitUserID.self)){ user ,newUserData in
            user.EmfitDeviceID = newUserData.EmfitDeviceID
            user.emfitLastDate = newUserData.emfitLastDate
            return user.save(on: req)
        }
    }
    
    //サブユーザー情報の更新
    func updateSubUser(_ req:Request) throws -> Future<SubUser>{
        
        return try flatMap(to:SubUser.self,req.parameters.next(SubUser.self), req.content.decode(updateUserdata.self)){ user ,newUserData in
         
            user.name = newUserData.name
            user.username = newUserData.username
            user.password = try BCrypt.hash(newUserData.password)
            user.birthday = newUserData.birthday
            user.comment = newUserData.comment
            user.gender = newUserData.gender
            user.height = newUserData.height
            user.weight = newUserData.weight
            user.nickname = newUserData.nickname
            
            return user.save(on: req)
        }
    }
    //サブユーザーのEmfit情報の更新
    func subEmfitUpdate(_ req:Request) throws -> Future<SubUser>{
          return try flatMap(to:SubUser.self,req.parameters.next(SubUser.self), req.content.decode(EmfitUserID.self)){ user ,newUserData in
            user.EmfitDeviceID = newUserData.EmfitDeviceID
            user.emfitLastDate = newUserData.emfitLastDate
            return user.save(on: req)
        }
    }
    
    //ユーザー作成
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        //タイムスタンプの作成
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateformatter.dateFormat = "yyyy"
        user.firstDate = dateformatter.string(from:Date())
        //月
        let monthDate = DateFormatter()
        monthDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        monthDate.dateFormat = "MM"
        user.month = monthDate.string(from:Date())
        //日
        let dayDate = DateFormatter()
        dayDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        dayDate.dateFormat = "dd"
        user.dayTime = dayDate.string(from: Date())
        return user.save(on: req).convertToPublic()
    }
    
    //ユーザー詳細
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    //ログイン
    func userloginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/login")
    }
    
}
