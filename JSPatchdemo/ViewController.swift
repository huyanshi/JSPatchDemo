//
//  ViewController.swift
//  JSPatchdemo
//
//  Created by 胡琰士 on 16/10/31.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 继承与NSObject的类可以使用tuntime的特新，swift类并没有这种特性，需要使用这种特性需要在方法和属性前面加 dynamic 进行修饰
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        methodSwizzling(object_getClass(self), originalSelector: Selector("viewDidAppear:"), swizzledSelector: Selector("testViewDidAppear:"))
        methodSwizzling(object_getClass(self), originalSelector: Selector("testReturnVoidWithaId:"), swizzledSelector: Selector("hz_testReturnVoidWithaId:"))
        testReturnVoidWithaId(self.view)
        let image = UIImage(named: "app_icon")?.imageWithCornerRadius(50)
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 100, y: 200, width: 200, height: 200)
        
        view.addSubview(imageView)
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.text = "tableViewGroup"
        btn.titleLabel?.font = UIFont.systemFontOfSize(16)
        btn.setTitle("tableViewGroup", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.redColor()
        btn.addTarget(self, action: "clickTableView", forControlEvents: UIControlEvents.TouchUpInside)
        btn.frame = CGRect(x: 100, y: 70, width: 100, height: 30)
        view.addSubview(btn)
        let btn1 = UIButton(type: .Custom)
        btn1.titleLabel?.text = "jspatch"
        btn1.titleLabel?.font = UIFont.systemFontOfSize(16)
        btn1.setTitle("jspatch", forState: UIControlState.Normal)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn1.backgroundColor = UIColor.redColor()
        btn1.addTarget(self, action: "clickJspatch", forControlEvents: UIControlEvents.TouchUpInside)
        btn1.frame = CGRect(x: 100, y: 110, width: 100, height: 30)
        view.addSubview(btn1)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func clickTableView() {
        let vc = GroupTableViewController()
        self.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        
    }
    func clickJspatch() {
        let vc = TestViewController()
        self.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("F:\(__FUNCTION__)L:\(__LINE__)")
    }
    
    func testViewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("F:\(__FUNCTION__)L:\(__LINE__)")
    }
    func testReturnVoidWithaId(aId:UIView){
        print("F:\(__FUNCTION__)L:\(__LINE__)")
    }
    func hz_testReturnVoidWithaId(aId:UIView){
        print("F:\(__FUNCTION__)L:\(__LINE__)")
    }
    //方法交换
    func methodSwizzling(cls:AnyClass, originalSelector:Selector,swizzledSelector:Selector) {
        let originalMethod = class_getInstanceMethod(cls, originalSelector)
        let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        
        let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod),  method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        
    }
    
}
extension UIImage {
    //圆角图片
    func imageWithCornerRadius(radius:CGFloat) -> (UIImage) {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, cornerRadius: radius).CGPath)
        CGContextClip(UIGraphicsGetCurrentContext())
        self.drawInRect(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    //图片等比压缩
    func scaleToSize(size:CGSize) -> (UIImage) {
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size)
        // 绘制改变大小的图片
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 从当前context中创建一个改变大小后的图片
        let scaledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        //返回新的改变大小后的图片
        return scaledImage
    }
    func imageCompressForSize(targetSize size:CGSize) -> (UIImage?){
        var newImage:UIImage?
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetheight = size.height
        var scaleFactor:CGFloat = 0.0
        var scaledWidth = targetWidth
        var scaledHeight = targetheight
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        
        if CGSizeEqualToSize(imageSize, size) == false {
            let widthFactor = targetWidth / width
            let heightFactor = targetheight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            }else {
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetheight - scaledHeight) * 0.5
            }else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContext(size)
        var thumbnailRect = CGRectZero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        self.drawInRect(thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let _ = newImage else{
            print("scale image fail")
            return nil
        }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imageCompressForWidth(targetWidth defineWidth:CGFloat) -> (UIImage?){
        var newImage:UIImage?
        let imageSize = self.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = defineWidth
        let targetheight = height / (width / targetWidth)
        let size = CGSize(width: targetWidth, height: targetheight)
        var scaleFactor:CGFloat = 0.0
        var scaledWidth = targetWidth
        var scaledHeight = targetheight
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        
        if CGSizeEqualToSize(imageSize, size) == false {
            let widthFactor = targetWidth / width
            let heightFactor = targetheight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            }else {
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetheight - scaledHeight) * 0.5
            }else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        UIGraphicsBeginImageContext(size)
        var thumbnailRect = CGRectZero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        self.drawInRect(thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let _ = newImage else{
            print("scale image fail")
            return nil
        }
        UIGraphicsEndImageContext()
        return newImage
    }

}

