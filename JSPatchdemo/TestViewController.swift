//
//  TestViewController.swift
//  JSPatchDome
//
//  Created by 胡琰士 on 16/9/29.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    private let listArr:[String] = ["","",""]
    override func viewDidLoad() {
        super.viewDidLoad()
        JPEngine.startEngine()
        JPEngine.evaluateScript("var alertView = require('UIAlertView').alloc().init(); \n alertView.setTitle('警告'); \n alertView.setMessage('JS正在靠近！');\n alertView.addButtonWithTitle('OK');\n alertView.show();")
        view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private lazy var tableView:UITableView = {
       let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height), style: UITableViewStyle.Plain)
        tableView.rowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

}
extension TestViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = "这是native下的第\(indexPath.row)个cell"
        return cell
    }
}