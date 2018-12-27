//
//  Modal.swift
//  Demo
//
//  Created by oncezou on 2018/12/26.
//  Copyright © 2018年. All rights reserved.
//
import RealmSwift
import Foundation

class BaseModel: Object {
    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var createAt = Date().timeIntervalSince1970
    @objc dynamic var updatedAt = Date().timeIntervalSince1970
    @objc dynamic var deleted = false
    @objc dynamic var synced = false
    
    @objc dynamic var tmpID = 0
    
    // 主键
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    // 被忽略属性
    override static func ignoredProperties() -> [String] {
        return ["tmpID"]
    }
}

class Person: BaseModel {
    @objc dynamic var fullName = ""
    /*
     * List 只能够包含 Object 类型，诸如 String 之类的基础类型是无法包含在内的。
     */
    let books = List<Book>() // 多对多关系
    let cars = List<Car>() // 多对多关系
}

class Book: BaseModel {
    @objc dynamic var name = ""
    // 使用 RealmOptional 类型来声明可空数值类型,RealmOptional 支持 Int、Float、Double、Bool
    let price = RealmOptional<Double>()
    // String、Date 以及 Data 属性能够通过标准的 Swift 语法来声明为可空类型或者必需（非空）类型。ower默认为nil
    @objc dynamic var ower: Person? //  多对一关系
    
    // 索引属性
    /*
     *，索引会稍微减慢写入速度，但是使用比较运算符进行查询的速度将会更快（它同样会造成 Realm 文件体积的增大，因为需要存储索引。）当您需要为某些特定情况优化读取性能的时候，那么最好添加索引。
     */
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

class Car: BaseModel {
    @objc dynamic var mode = ""
    @objc dynamic var brand = ""
    let owners = LinkingObjects(fromType: Person.self, property: "cars") // 双向关系
}
