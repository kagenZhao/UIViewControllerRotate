//
//  UIViewController+Rotation.m
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 屏幕旋转控制类, 耦合性低, 但因为用到了runtime 所以有侵入性,
 
 使用情景:
    现在市面上大部分app 并不是所有页面都可以旋转屏幕, 一般只有些许几个页面需要旋转屏幕, 比如查看文档, 观看视频等界面.
    这个扩展应运而生, 专门管理这个旋转状态, 默认界面都禁止旋转, 需要旋转的界面重写系统方法即可.
 
 为什么用OC:
    如果按照一般的写法, 就应该是创建BaseViewController, BaseNavigationController, BaseTabBarController 这三个基类,
    修改其 shouldAutorotate, supportedInterfaceOrientations, preferredInterfaceOrientationForPresentation 方法来实现个别界面旋转效果
    但是这样项目的耦合性就非常大, 需要所有类都进行继承, 所以想到用扩展的方法实现, 但是swift的extension 不支持重写父类方法, 所以这里用OC实现
 
 使用方法:
    只需要在项目中引入文件,
    在需要旋转的界面重写:
    shouldAutorotate  默认返回 true / YES
    supportedInterfaceOrientations 默认返回 UIInterfaceOrientationMaskPortrait
    preferredInterfaceOrientationForPresentation 默认返回 UIInterfaceOrientationPortrait
    preferredStatusBarStyle 默认返回 UIStatusBarStyleDefault
    prefersStatusBarHidden 默认返回 NO
    等方法即可 非常低耦合
 
    PS.如遇到某些类想要强制修改其方向, 需要用到 UIViewControllerRotationModel 进行设置
 
 风险提示:
    本扩展使用runtime替换了以下方法, 如果有冲突请自行修改或寻找其他解决方案:
    UIViewController:
        @selector(dismissViewControllerAnimated:completion:)
        @selector(viewWillAppear:)
    UINavigationController:
        @selector(pushViewController:animated:)
        @selector(popToViewController:animated:)
        @selector(popToRootViewControllerAnimated:)
    UITabBarController:
        @selector(setSelectedIndex:)
        @selector(setSelectedViewController:)
    UIApplication:
        @selector(setDelegate:)
    UIApplication.delegate
         @selector(application:supportedInterfaceOrientationsForWindow:)
 */

@interface UIViewControllerRotationModel : NSObject

- (instancetype)initWithDefault:(NSString *)cls; // 默认不改变这个类

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

- (instancetype)initWithCls:(NSString *)cls
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden;

- (instancetype)initWithCls:(NSString *)cls
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;

- (instancetype)initWithCls:(NSString *)cls
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden;

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden;


- (void)conigShouldAutorotate:(BOOL)shouldAutorotate;
- (void)conigSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (void)conigPrefersStatusBarHidden:(UIInterfaceOrientation)prefersStatusBarHidden;
- (void)conigPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;
- (void)conigPreferredInterfaceOrientationForPresentation:(BOOL)preferredInterfaceOrientationForPresentation;

@end

@interface UIViewController (Rotation)

/*
 如果发现某个系统的类或者第三方框架中的类需要或者不需要旋转的话 请在Appdelegate 中进行注册
 */
+ (void)registerClass:(NSArray<UIViewControllerRotationModel *> *)models;

@end

@interface UIApplication (Rotation)
@end
