//
//  ViewController.swift
//  过目
//
//  Created by 金乃德 on 2018/1/5.
//  Copyright © 2018年 金乃德. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let animatorDuration1 = 0.4 //界面反转时间
    let animatorDuration2 = 0.4 //界面反转时间
    let animatorDuration3 = 0.1 //按钮颜色变换时间
    let animatorDuration4 = 0.4 //界面划走时间
    let animatorDuration5 = 1.2 //后界面显现时间
    
    var mainCenter : CGPoint!
    var animator1, animator2,                                              //翻转动画
        animatorOfLeftButton, animatorOfMidButton, animatorOfRightButton,  //按钮颜色变换动画
        animatorOfDragToRight,animatorOfDragToLeft,animatorOfDragToTop,    //界面划走动画
        animatorOfAppear                                                   //后界面显现动画
        : UIViewPropertyAnimator!
    
    var widthOfSubview1 : CGFloat! //界面页的宽度
    var subview1 : UIView!//界面页
    var subview2 : UIView!//主题页
    
    @IBOutlet weak var leftButton: UIButton!    //左按钮
    @IBOutlet weak var midButton: UIButton!     //中间按钮
    @IBOutlet weak var rightButton: UIButton!   //右按钮
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        subview1 = self.view.subviews[0]
        subview2 = self.view.subviews[1]
        
        widthOfSubview1 = subview1.frame.width
        
        //将按钮放入界面页的子视图
        subview1.addSubview(leftButton)
        subview1.addSubview(midButton)
        subview1.addSubview(rightButton)
        
        //设置界面页的属性
        subview1.layer.masksToBounds = true
        subview1.layer.cornerRadius = 4
        subview1.backgroundColor = UIColor.white
        subview1.layer.shadowColor = UIColor.black.cgColor
        subview1.layer.shadowOpacity = 1.0
        subview1.layer.borderWidth = 0.1
        subview1.layer.borderColor = UIColor.darkGray.cgColor
        
        //设置主题页的属性
        subview2.layer.masksToBounds = true
        subview2.layer.cornerRadius = 8
        subview2.backgroundColor = UIColor.white
        subview2.layer.shadowColor = UIColor.black.cgColor
        subview2.layer.shadowOpacity = 1.0
        subview2.layer.borderWidth = 0.1
        subview2.layer.borderColor = UIColor.darkGray.cgColor
        
        //界面页的手势识别
        subview1.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragView)))
        
        //主题页的手势识别
        subview2.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(tapView1)))
        
        
        aniInit() //动画的初始化
        
        
    }
    
    var isUp = false //界面页是否在向上移动？
    var lock = false //移动是否锁住
    
    //检查移动是否锁住
    func checkLock(deltaX:CGFloat,deltaY:CGFloat){
        if deltaX>1 || deltaY > 1{
            lock = true
            if deltaX * 2 < deltaY {
                isUp = true
            }else{
                isUp = false
            }
        }
    }
    
    //旋转角度计算 根据横坐标得到纵坐标
    func getY(x:CGFloat) -> CGFloat{
        let width = self.view.subviews[0].bounds.width
        let temp : Double = Double(width)
        let tempx : Double = Double(x)
        return CGFloat(sqrt(pow(7.21 * temp, 2) - tempx * tempx) - 7.12 * temp) - 35
    }
    
    //界面页的滑动操作
    @objc func dragView(gesture: UIPanGestureRecognizer) {
        let target = gesture.view!
        let translation = gesture.translation(in: target)
        
        let d_x = abs(translation.x)
        let d_y = abs(translation.y)
        switch gesture.state {
        case .began:
            mainCenter = target.center
        case .changed:
            if !lock {
                
                checkLock(deltaX: d_x, deltaY: d_y) //检查动作是否锁住，若没有，则锁住
                
                if d_x * 2 < d_y {      //y坐标绝对值大于2倍的x坐标绝对值，将中间按钮覆盖其他按钮
                    target.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                    aniInit()
                    animatorOfMidButton.startAnimation()
                } else {
                    if translation.x < 0 {      //y坐标绝对值不大于2倍的x坐标绝对值，则若x坐标为正，将左按钮覆盖其他按钮
                        target.transform = CGAffineTransform(translationX: translation.x, y: getY(x: translation.x))
                        aniInit()
                        animatorOfLeftButton.startAnimation()
                    }
                    else if translation.x > 0{      //y坐标绝对值不大于2倍的x坐标绝对值，则若x坐标为负，将右按钮覆盖其他按钮
                        target.transform = CGAffineTransform(translationX: translation.x, y: getY(x: translation.x))
                        aniInit()
                        animatorOfRightButton.startAnimation()
                        
                    }
                }
            } else {
                if isUp {       //如果锁在向上的状态，保持向上滑动，并将中按钮覆盖其他按钮
                    target.transform = CGAffineTransform(translationX: 0, y: translation.y)
                    aniInit()
                    animatorOfMidButton.startAnimation()
                } else {        //没有锁在向上的状态，抱持左右滑动
                    target.transform = CGAffineTransform(translationX: translation.x, y: getY(x: translation.x))
                }
            }
        case .ended:
            if isUp && d_y > target.frame.height/4 {        //松手后y坐标绝对值改变距离大于界面页四分之一高度且是向上的话，启动向上滑走的动画，显现主题页
                animatorOfDragToTop.startAnimation()
                animatorOfAppear.startAnimation()
                aniInit()
            }
            else if translation.x > target.frame.width/3 {      //松手后x坐标改变距离大于界面页宽度的三分之一时，启动向右滑走的动画，显现主题页
                animatorOfDragToRight.startAnimation()
                animatorOfAppear.startAnimation()
                aniInit()
                
            }
            else if translation.x < -target.frame.width/3{      //松手后x坐标改变距离小于界面页宽度三分之一的负数时，启动向左滑走的动画，显现主题页
                animatorOfDragToLeft.startAnimation()
                animatorOfAppear.startAnimation()
                aniInit()
            }
            else{
                target.transform = CGAffineTransform(translationX: 0, y: 0)     //松手后没有达到上面的条件则将界面位置还原
            }
            lock = false        //解锁
            isUp = false
            butInit()           //初始化按键
        default: break
        }
    }
    
    //主题页的点按操作
    @objc func tapView1(gesture: UITapGestureRecognizer){
        subview1.alpha = 0
        subview1.layer.transform = CATransform3DMakeRotation(CGFloat(.pi * 1.0), 0, -1, 0)
        animator1.startAnimation()
        animator2.startAnimation()
        subview2.layer.transform = CATransform3DMakeRotation(CGFloat(.pi * 1.0), 0, 0, 0)
        butInit()
    }
    
    //三个按钮的动作
    @IBAction func leftButtonTouch(_ sender: UIButton) {
        animatorOfLeftButton.startAnimation()
        animatorOfDragToLeft.startAnimation()
        animatorOfAppear.startAnimation()
        aniInit()
    }
    
    @IBAction func MidButtonTouch(_ sender: UIButton) {
        animatorOfMidButton.startAnimation()
        animatorOfDragToTop.startAnimation()
        animatorOfAppear.startAnimation()
        aniInit()
    }
    
    @IBAction func rightButton(_ sender: UIButton) {
        animatorOfRightButton.startAnimation()
        animatorOfDragToRight.startAnimation()
        animatorOfAppear.startAnimation()
        aniInit()
    }
    
    // 按键初始化
    func butInit(){
        let width = widthOfSubview1/3
        
        //左按钮
        leftButton.frame = CGRect(x: 0, y: subview1.bounds.maxY-72, width: width, height: 72)
        leftButton.setTitleColor(UIColor.lightGray, for: .normal )
        leftButton.alpha = 1
        leftButton.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9764705882, blue: 0.9843137255, alpha: 1)
        leftButton.layer.borderWidth = 0.15
        leftButton.layer.borderColor = UIColor.lightGray.cgColor
        
        //中按钮
        midButton.frame = CGRect(x: width, y: subview1.bounds.maxY-72, width: width, height: 72)
        midButton.setTitleColor(UIColor.lightGray, for: .normal )
        midButton.alpha = 1
        midButton.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9764705882, blue: 0.9843137255, alpha: 1)
        midButton.layer.borderWidth = 0.1
        midButton.layer.borderColor = UIColor.lightGray.cgColor


        
        //右按钮
        rightButton.frame = CGRect(x: width*2, y: subview1.bounds.maxY-72, width: width, height: 72)
        rightButton.setTitleColor(UIColor.lightGray, for: .normal )
        rightButton.alpha = 1
        rightButton.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9764705882, blue: 0.9843137255, alpha: 1)
        rightButton.layer.borderWidth = 0.1
        rightButton.layer.borderColor = UIColor.lightGray.cgColor


    }
    
    //按键动画初始化
    func aniInit(){
        //界面页的翻转
        animator1 = UIViewPropertyAnimator(duration: animatorDuration1, curve:.easeOut, animations: {
            self.subview1.layer.transform = CATransform3DMakeRotation(CGFloat(.pi * 1.0), 0, 0, 0)
            self.subview1.alpha = 1
        })
        
        //主题页的翻转
        animator2 = UIViewPropertyAnimator(duration: animatorDuration2, curve:.easeIn, animations: {
            self.subview2.layer.transform = CATransform3DMakeRotation(CGFloat(.pi * 1.0), 0, -1, 0)
            self.subview2.alpha = 0
        })
        
        //左按钮的颜色宽度改变
        animatorOfLeftButton = UIViewPropertyAnimator(duration: animatorDuration3, curve: .easeInOut, animations: {
            self.leftButton.frame = CGRect(x: 0, y: self.subview1.bounds.maxY-72, width: self.subview1.frame.width, height: 72)
            
            self.leftButton.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)
            self.leftButton.setTitleColor(UIColor.white, for: .normal )
            
            self.midButton.alpha = 0
            self.rightButton.alpha = 0
        })
        
        //中间按钮的颜色宽度改变
        animatorOfMidButton = UIViewPropertyAnimator(duration: animatorDuration3, curve: .easeInOut, animations: {
            self.midButton.frame = CGRect(x: 0, y: self.subview1.bounds.maxY-72, width: self.subview1.frame.width, height: 72)
            
            self.midButton.backgroundColor = #colorLiteral(red: 1, green: 0.7333333333, blue: 0.3176470588, alpha: 1)
            self.midButton.setTitleColor(UIColor.white, for: .normal )
            
            self.leftButton.alpha = 0
            self.rightButton.alpha = 0
        })
        
        //右按钮的颜色宽度改变
        animatorOfRightButton = UIViewPropertyAnimator(duration: animatorDuration3, curve: .easeInOut, animations: {
            self.rightButton.frame = CGRect(x: 0, y: self.subview1.bounds.maxY-72, width: self.subview1.frame.width, height: 72)
            
            self.rightButton.backgroundColor = #colorLiteral(red: 0.8509803922, green: 0.8745098039, blue: 0.8980392157, alpha: 1)
            self.rightButton.setTitleColor(UIColor.white, for: .normal )
            
            self.leftButton.alpha = 0
            self.midButton.alpha = 0
        })
        
        //滑向右边
        animatorOfDragToRight = UIViewPropertyAnimator(duration: animatorDuration4, curve: .easeInOut, animations: {
            
            self.subview1.transform = CGAffineTransform(translationX: self.view.frame.width, y: self.getY(x: self.view.frame.width))
            
        })
        
        //滑向左边
        animatorOfDragToLeft = UIViewPropertyAnimator(duration: animatorDuration4, curve: .easeInOut, animations: {
            
            self.subview1.transform = CGAffineTransform(translationX: -self.view.frame.width, y: self.getY(x: -self.view.frame.width))
        })
        
        //滑向上
        animatorOfDragToTop = UIViewPropertyAnimator(duration: animatorDuration4, curve: .easeInOut, animations: {
            self.subview1.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
            
        })
        
        //主题页显现
        animatorOfAppear = UIViewPropertyAnimator(duration: animatorDuration5, curve: .easeInOut, animations: {
            
            self.subview2.alpha = 1
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

