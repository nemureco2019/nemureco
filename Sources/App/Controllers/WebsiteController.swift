//
//  WebsiteController.swift
//  App
//
//  Created by 本田悠隼 on 2019/06/25.
//
import Vapor
import Foundation
import Authentication
import FluentPostgreSQL

struct WebsightController:RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        //ユーザーの作成
        authSessionRoutes.get("register", use: registerViewer)
        authSessionRoutes.post(RegisterData.self,at:"register", use: registerPostHandler)
        //ログインをしていないとログイン画面に移動する
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        //ログインチェック
        authSessionRoutes.post(LoginPostData.self,at:"login", use: loginPostHandler)
        authSessionRoutes.get("login",use: loginHandler)
        //ログアウト
        authSessionRoutes.get("logout", use:logoutViewer)
        authSessionRoutes.post("logout", use: logoutHandler)
        //ユーザー全員
        protectedRoutes.get("user", use:allUserViewer)
        //SleepData（User）
        protectedRoutes.get("sleepin",User.parameter, use: sleepDataUserViewer)
        //Sleep<Weak>
        protectedRoutes.get("weakas",User.parameter, use: SleepDataAscending)
        //Sleep<User><入眠><Descending>
        protectedRoutes.get("indes",User.parameter, use: outSleepDataDes)
        //SleepData<User><Ascending>
        protectedRoutes.get("assleep",User.parameter, use: inSleepAscending)
        
        //ログイン後の画面
        protectedRoutes.get("menu", use: menuViewer)
        //ユーザーの詳細
        protectedRoutes.get("detail",User.parameter, use: userDetailViewer)
         //期間検索
        protectedRoutes.get("search",User.parameter, use: dataSearchViewer)
        //睡眠データの全件取得
        protectedRoutes.get("datacsv", use: sleepDataAllViewer)
     
        
    }

    //AllData
    func sleepDataAllViewer(_ req:Request) throws -> Future<View>{
        return SleepData.query(on: req).all().flatMap(){ sleepData in
            let context = SleepDataSearcher(sleepData: sleepData)
            return try req.view().render("sleepdataAll",context)
        }
    }

    
    //期間検索
    func dataSearchViewer(_ req:Request) throws -> Future<View>{
       
        guard  let searchTerm = req.query[String.self,at:"term"] else {
            throw Abort(.badRequest,reason:"該当するデータはありません")
        }
        //  search?term=
        return  SleepData.query(on: req).group(.or){ or in
            or.filter(\.carender == searchTerm)
       
            }.all().flatMap(to:View.self){ data in
                let context = SleepDataSearcher(sleepData: data)
                return try req.view().render("sleepdataviewer",context)
    
      }
    }
    
    //Userの詳細
    func userDetailViewer(_ req:Request) throws -> Future<View>{
        return try req.parameters.next(User.self).flatMap(to:View.self){ user in
       
            let context = menuContext(user: user)
            return try req.view().render("UserDetail",context)
            
        }
    }
    
    //SleepDataの表示<入眠>(User)(.ascending)
    func inSleepAscending(_ req:Request) throws -> Future<View>{
        return try req.parameters.next(User.self).flatMap(to:View.self){ user in
            return  try user.sleepData.query(on: req).sort(\.sleep,.ascending).all().flatMap(to:View.self){ sleepData in
                return User.query(on: req).all().flatMap(to:View.self){ users in
                    let context = usersSleepdataContext(user:user,sleepData:sleepData,users:users)
                    return try req.view().render("sleepdataviewer",context)
                }
            }
        }
    }
    //SleepData<User><.desu>
    func outSleepDataDes(_ req:Request) throws -> Future<View>{
        return try req.parameters.next(User.self).flatMap(to:View.self){ user in
            return  try user.sleepData.query(on: req).sort(\.sleep,.descending).all().flatMap(to:View.self){ sleepData in
                return User.query(on: req).all().flatMap(to:View.self){ users in
                    let context = usersSleepdataContext(user:user,sleepData:sleepData,users:users)
                    return try req.view().render("sleepdataviewer",context)
                }
            }
        }    }
    
    
    //SleepDataの表示(User)(.ascending)<weak>
    func sleepDataUserViewer(_ req:Request) throws -> Future<View>{
        return try req.parameters.next(User.self).flatMap(to:View.self){ user in
        return  try user.sleepData.query(on: req).sort(\.weakUP,.ascending).all().flatMap(to:View.self){ sleepData in
     return User.query(on: req).all().flatMap(to:View.self){ users in
        let context = usersSleepdataContext(user:user,sleepData:sleepData,users:users)
                return try req.view().render("sleepdataviewer",context)
                }
            }
        }
    }
     //SleepDataの表示(User)(.descending)<weak>
    func  SleepDataAscending(_ req:Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to:View.self){ user in
            return  try user.sleepData.query(on: req).sort(\.weakUP,.descending).all().flatMap(to:View.self){ sleepData in
                return User.query(on: req).all().flatMap(to:View.self){ users in
                    let context = usersSleepdataContext(user:user,sleepData:sleepData,users:users)
                    return try req.view().render("sleepdataviewer",context)
                }
            }
        }
    }
    
    
    //ログイン
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(username: userData.username, password: userData.password, using: BCryptDigest(), on: req).map(to: Response.self) { user in
            //失敗
            guard let user = user else {
                return req.redirect(to:"/login")
            }
            //成功
            try req.authenticateSession(user)
            return req.redirect(to:"/menu")
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("login", LoginContext())
    }
    //ログアウト
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        print("Logout")
        return req.redirect(to:"/")
    }
    
    //ログアウト
    func logoutViewer(_ req:Request) throws -> Future<View>{
        return try req.view().render("logout")
    }
    
    //ユーザー作成
    func registerViewer(_ req:Request) throws -> Future<View>{
        var context = RegisterContext()
        if req.query[Bool.self, at: "error"] != nil {
            context.registrationError = true
        }
        return try req.view().render("register", context)
    }
    
    //PostでUser作成
    func registerPostHandler(_ req: Request, data: RegisterData) throws -> Future<Response> {
        let password = try BCrypt.hash(data.password)
        //タイムスタンプの作成
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateformatter.dateFormat = "yyyy"
        let firstDate = dateformatter.string(from: Date())
        //月
        let monthDate = DateFormatter()
        monthDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        monthDate.dateFormat = "MM"
        let month = monthDate.string(from:Date())
        //日
        let dayDate = DateFormatter()
        dayDate.timeZone =  TimeZone(identifier: "Asia/Tokyo")
        dayDate.dateFormat = "dd"
        let dayTime = dayDate.string(from: Date())
        
        let emfit = ""
        
        let user = User(name: data.name, username: data.username, password: password, birthday: data.birthday, comment: data.comment, gender: data.gender,
                        height: data.height, nickname: data.nickname, dayTime: dayTime, month: month, weight: data.weight, firstDate: firstDate,EmfitDeviceID:emfit ,emfitLastDate:emfit)
        return user.save(on: req).map(to: Response.self) { user in
            try req.authenticateSession(user)
            return req.redirect(to:"/menu")
        }
    }
    
    //Menu
    func menuViewer(_ req:Request) throws -> Future<View>{
        let user = try req.requireAuthenticated(User.self)
        let context = menuContext(user: user)
        return try req.view().render("menu",context)
    }
    //ALL User&SleepData
    func allUserViewer(_ req:Request) throws -> Future<View>{
        return User.query(on: req).all().flatMap(to:View.self){ user in
     
            //Response
            let context = AllUserContext(user: user)
            return try req.view().render("allUser",context)
        
        }
    }
}
