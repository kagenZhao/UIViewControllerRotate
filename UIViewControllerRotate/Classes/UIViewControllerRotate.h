//
//  UIViewController+Rotation.m
//
//  Created by kagen on 2018/7/11.
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

目前已经包含的内部类包括:
1. AVFullScreenViewController
2. AVPlayerViewController
3. AVFullScreenViewController
4. AVFullScreenPlaybackControlsViewController
5. WebFullScreenVideoRootViewController
6. UISnapshotModalViewController
7. UIAlertController // 10.0以下递归崩溃
 
 风险提示:
    本扩展使用runtime替换了以下方法, 如果有冲突请自行修改或寻找其他解决方案:
    UIViewController:
        @selector(presentViewController:animated:completion:)
        @selector(dismissViewControllerAnimated:completion:)
        @selector(viewWillAppear:)
    UINavigationController:
        @selector(pushViewController:animated:)
        @selector(popViewControllerAnimated:)
        @selector(popToViewController:animated:)
        @selector(popToRootViewControllerAnimated:)
    UITabBarController:
        @selector(setSelectedIndex:)
        @selector(setSelectedViewController:)
    UIApplication:
        @selector(setDelegate:)
    UIApplication.delegate
        // 强制返回ALL, 否则会导致 presented 的 界面 dismiss 时 crash
         @selector(application:supportedInterfaceOrientationsForWindow:)
 */
NS_ASSUME_NONNULL_BEGIN

@protocol UIApplicationOrientationDefault <NSObject>
@optional
@property (class, nonatomic, assign, readonly) BOOL disableMethidSwizzle; // default NO. 禁止方法交换可能会导致横竖屏异常, 此方法只用来debug, 如果冲突请删除本库, 并选择其他横屏方案.
@property (class, nonatomic, assign, readonly) BOOL defaultShouldAutorotate; // default YES
@property (class, nonatomic, assign, readonly) UIInterfaceOrientationMask defaultSupportedInterfaceOrientations; // default UIInterfaceOrientationMaskPortrait
@property (class, nonatomic, assign, readonly) UIInterfaceOrientation defaultPreferredInterfaceOrientationForPresentation; // default UIInterfaceOrientationPortrait
@property (class, nonatomic, assign, readonly) UIStatusBarStyle defaultPreferredStatusBarStyle; // default UIStatusBarStyleDefault
@property (class, nonatomic, assign, readonly) BOOL defaultPrefersStatusBarHidden; // default NO
@end

@interface UIApplication (Rotation) <UIApplicationOrientationDefault>
/*
 UIApplicationOrientationDefault 协议 需要自行实现其方法
 */
@end

__attribute__((objc_subclassing_restricted))
@interface UIViewControllerRotationModel : NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *cls;

- (instancetype)initWithClass:(NSString *)cls; // 默认不改变这个类

- (instancetype)configShouldAutorotate:(BOOL)shouldAutorotate;
- (instancetype)configSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (instancetype)configPrefersStatusBarHidden:(UIInterfaceOrientation)prefersStatusBarHidden;
- (instancetype)configPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle;
- (instancetype)configPreferredInterfaceOrientationForPresentation:(BOOL)preferredInterfaceOrientationForPresentation;

/*
 可以通过打印来查看具体内容
 */
- (NSString *)description;
- (NSString *)debugDescription;
@end


/**
 这里公开了已经处理的系统内部类:
 默认包含:
 1. AVFullScreenViewController
 2. AVPlayerViewController
 3. AVFullScreenViewController
 4. AVFullScreenPlaybackControlsViewController
 5. WebFullScreenVideoRootViewController
 6. UISnapshotModalViewController
 
 如果发现某个系统的类或者第三方框架中的类需要或者不需要旋转的话 请在Appdelegate 中调用下方 registerClasses: 方法进行注册

 建议不要删除默认这些类, 删除后会引起崩溃, 比如: AVFullScreenViewController
 
 @return 公开已经处理的系统内部类
 */
static inline NSArray <UIViewControllerRotationModel *> * __UIViewControllerDefaultRotationClasses() {
    NSArray <NSString *>*classNames = @[@"AVFullScreenViewController",
                                        @"AVPlayerViewController",
                                        @"AVFullScreenViewController",
                                        @"AVFullScreenPlaybackControlsViewController",
                                        @"WebFullScreenVideoRootViewController",
                                        @"UISnapshotModalViewController",
                                        NSStringFromClass(UIAlertController.class),
                                        ];
    NSMutableArray <UIViewControllerRotationModel *> * result = [NSMutableArray arrayWithCapacity:classNames.count];
    [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:[[[[UIViewControllerRotationModel alloc]
                             initWithClass:className]
                            configShouldAutorotate:true]
                           configSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll]];
    }];
    return result;
}

@interface UIViewController (Rotation)


/**
 注册内部不能实例化的类, 使其强制应用某些旋转特性

 @param models 要注册的类转换成的Model, 支持多个
 */
+ (void)registerClasses:(NSArray<UIViewControllerRotationModel *> *)models;

/**
 查看已经注册的内部类

 @return 已经注册的类转换成的Model
 */
+ (NSArray <UIViewControllerRotationModel *> *)registedClasses;

/**
 若想要删除某些不需要的类, 则调用此方法

 @param classes 类名字符串列表
 */
+ (void)removeClasses:(NSArray<NSString *> *)classes;
@end
NS_ASSUME_NONNULL_END
