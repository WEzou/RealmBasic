//
//  ViewController.swift
//  Demo
//
//  Created by oncezou on 2018/11/15.
//  Copyright © 2018年 . All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    let btnWidth: CGFloat = 150
    let btnHeight: CGFloat = 40
    
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeRealm()
        
        creatButton("AddRealm", 200, #selector(addRealm))
        creatButton("UpdateRealm", 100, #selector(updateRealm))
        creatButton("QueryRealm", 0, #selector(queryRealm))
        creatButton("Next", -100, #selector(nextPage))
        view.backgroundColor = UIColor.white
    }
    
    func creatButton(_ title: String,_ margin: CGFloat,_ action: Selector) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.orange
        button.frame =  CGRect(x: (width-btnWidth)/2, y: height/2-margin, width: btnWidth, height: btnHeight)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func addRealm() {
        // 创建对象
        let car = Car(value: ["brand":"丰田","mode":"凯美瑞"])
        let book1 = Book(value: ["name":"百年孤独","price":59.9])
        let book2 = Book(value: ["name":"人性的缺点","price":39.9])
        let book3 = Book(value: ["name":"百年孤独","price":99.9])
        let person = Person()
        person.fullName = "oncezou"
        person.books.append(book1)
        person.books.append(book2)
        person.books.append(book3)
        person.cars.append(car)
        
        // 更新\添加对象
        try! defaultRealm.write {
            defaultRealm.add(person)
        }
    }
    
    @objc func updateRealm() {
        // 查询结果
        // 所有的查询操作（包括检索和属性访问）在 Realm 中都是延迟加载的。只有当属性被访问时，数据才会被读取
        // 一旦执行了查询，或者添加了通知模块， 那么 Results 将时刻与 Realm 数据库当中的数据保持一致
        let cars = defaultRealm.objects(Car.self)
        print("cars == \(cars)")
        
        // 修改对象
        try! defaultRealm.write {
            cars.first?.brand = "本田"
            //允许 键值编码(KVC) 将每个 person 对象的 planet 属性设置为 "Earth"
            cars.setValue("雅阁", forKeyPath: "mode")
        }
        /* 结果的自更新
         * Object 实例是底层数据的动态体现，其会自动进行更新，这意味着您无需去重新检索结果。它们会直接映射出 Realm 数据库在当前线程中的状态，包括当前线程上的写入事务。唯一的例外是，在使用 for...in 枚举时，它会将刚开始遍历时满足匹配条件的所有对象给遍历完，即使在遍历过程中有对象被过滤器修改或者删除。
         *
         */
        print("brand == \(String(describing: cars.first!.brand))")
    }
    
    @objc func queryRealm() {
        /* 条件查询(NSPredicate语法)
         * 过滤、排序
         * 过滤（filter）可以链式查询
         * 排序 sorted(byKeyPath:) 和 sorted(byProperty:)
         */
        let books = defaultRealm.objects(Book.self).filter("name = '百年孤独'").sorted(byKeyPath: "price")
        print("books == \(books)")
        
        // sorted 不支持 将多个属性用作排序基准，此外也无法链式排序（只有最后一个 sorted 调用会被使用） 如果要对多个属性进行排序，请使用 sorted(by:) 方法，然后向其中输入多个 SortDescriptor 对象。
        let result = books.sorted(byKeyPath: "name")
        print("result == \(result)")
    }
    
    func observeRealm() {
        // 通知
        let token = defaultRealm.observe { (notification, realm) in
            print("notification == \(notification)")
        }
        
        // 集合通知
        let cars = defaultRealm.objects(Car.self)
        notificationToken = cars.observe { (changes) in
            switch changes {
            case .initial:
                print("initial")
            case .update(_, let deletions, let insertions, let modifications):
                print("update: \(deletions) \(insertions) \(modifications)")
            case .error(let error):
                print("error == \(error)")
            }
        }
        
        token.invalidate()
    }
    
    @objc func nextPage() {
        let tableCtl = TableViewController(style: .plain)
        self.navigationController?.pushViewController(tableCtl, animated: true)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



