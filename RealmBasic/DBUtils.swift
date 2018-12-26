//
//  DBUtils.swift
//  Demo
//
//  Created by oncezou on 2018/12/26.
//  Copyright © 2018年 FintendONCE. All rights reserved.
//

import RealmSwift
import Foundation

private let version: UInt64 = 2
public var defaultRealm: Realm!

// 初始化realm，username可试用于多用户切换
public func setupDefaultReaml(_ username: String = "oncezou") {
    var config = Realm.Configuration()
    let sharedURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
    if let originPath = config.fileURL?.path {
        print("originPath == \(originPath)")
        if FileManager.default.fileExists(atPath: originPath) {
            print("originPath == true)")
            _ = try? FileManager.default.moveItem(atPath: originPath, toPath: sharedURL.path)
        }
    }
    
    // 自定义realm的数据库路径，当然也可以使用默认的
    config.fileURL = sharedURL
    config.schemaVersion = version
    
    // 至少需要使用一个空闭包，从而表明该架构由 Realm 所（自动）升级完毕。
    /* 如果没有什么要做的！
     * Realm 会自行检测新增和被移除的属性
     * 然后会自动更新磁盘上的架构
     */
    config.migrationBlock = { migration, oldSchemaVersion in
        // eg:
        if oldSchemaVersion < 1 {
            // 针对Person做数据裤升级 firstName + lastName -> name
            migration.enumerateObjects(ofType: Person.className()) { oldObject, newObject in
                // combine name fields into a single field
                let firstName = oldObject!["firstName"] as! String
                let lastName = oldObject!["lastName"] as! String
                newObject?["name"] = "\(firstName) \(lastName)"
            }

            // 重命名操作必须要在 `enumerateObjects(ofType: _:)` 调用之外进行
            migration.renameProperty(onType: Person.className(), from: "name", to: "fullName")
            // ....
        }
    }
    Realm.Configuration.defaultConfiguration = config
    
    // 同步迁移
     defaultRealm = try! Realm()
    
    // 异步迁移
//    Realm.asyncOpen { (realm, error) in
//        if let realm = realm {
//            // 成功打开 Realm 数据库，迁移操作在后台线程中进行
//            defaultRealm = realm
//        } else if let error = error {
//            // 处理在打开 Realm 数据库期间所出现的错误
//            print("Realm.asyncOpen == \(error)")
//        }
//    }
}


