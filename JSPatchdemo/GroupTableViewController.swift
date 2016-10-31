//
//  GroupTableViewController.swift
//  JSPatchDome
//
//  Created by 胡琰士 on 16/9/12.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    //索引数字
    var dataSource:[String] = []
    var dataBase:[String] = []
    let cellIdentifier = "Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        //改变索引的颜色
        tableView.sectionIndexColor = UIColor.blueColor()
        //改变索引选中的背景颜色
        tableView.sectionIndexTrackingBackgroundColor = UIColor.grayColor()
        
        let letter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for char in letter.characters {
            dataSource.append(String(char))
        }

        
        /*
        用这个方法可以吧文字按照中文的拼音进行排序具体内容和更深的解释“ICU”
        查看：https://segmentfault.com/a/1190000004414753
        for i in 0..<datasource.count {
        datasource[i]["pinyin"] = datasource[i]["chinese"]!.stringByApplyingTransform(NSStringTransformToLatin, reverse: false)?.uppercaseString ?? "#"
        }
        datasource.sortInPlace({ $0["pinyin"] < $1["pinyin"] })

        */
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    //返回索引数组
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return dataSource
    }
    //响应点击索引时的委托方法
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var count = 0
        
        for char in dataSource {
            if char == title {
                return count
            }
            count++
        }
        return 0
    }
    //返回section的个数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return dataSource.count
    }
    //返回每个索引的内容
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section]
    }
    //返回每个section的行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    //cell内容
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = dataSource[indexPath.section] + "\(indexPath.row)"
        return cell!
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
            /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
