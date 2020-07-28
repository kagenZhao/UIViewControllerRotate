//
//  UIViewController+Rotation.m
//
//  Created by kagen on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/**
 可设置默认值
 */
@interface UIViewControllerRotateDefault : NSObject
@property (nonatomic, assign) BOOL disableMethidSwizzle; // default NO. 禁止方法交换可能会导致横竖屏异常, 此方法只用来debug, 如果冲突请删除本库, 并选择其他横屏方案.
@property (nonatomic, assign) BOOL defaultShouldAutorotate; // default YES
@property (nonatomic, assign) UIInterfaceOrientationMask defaultSupportedInterfaceOrientations; // default UIInterfaceOrientationMaskPortrait
@property (nonatomic, assign) UIInterfaceOrientation defaultPreferredInterfaceOrientationForPresentation; // default UIInterfaceOrientationPortrait
@property (nonatomic, assign) UIStatusBarStyle defaultPreferredStatusBarStyle; // default UIStatusBarStyleDefault
@property (nonatomic, assign) BOOL defaultPrefersStatusBarHidden; // default NO

+ (instancetype)shared;

@end


__attribute__((objc_subclassing_restricted))
@interface UIViewControllerRotationModel : NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSString *cls;

- (instancetype)initWithClass:(NSString *)cls containsSubClass:(BOOL)containsSubClass; // 默认不改变这个类
- (instancetype)configContainsSubClass:(BOOL)containsSubClass;
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
 3. AVFullScreenPlaybackControlsViewController
 4. WebFullScreenVideoRootViewController
 5. UISnapshotModalViewController

 如果发现某个系统的类或者第三方框架中的类需要或者不需要旋转的话 请在Appdelegate 中调用下方 registerClasses: 方法进行注册

 建议不要删除默认这些类, 删除后会引起崩溃, 比如: AVFullScreenViewController
 
 默认同时处理其子类, 若不想处理 请自行设置model的containsSubClass属性
 
 @return 公开已经处理的系统内部类
 */
static inline NSArray <UIViewControllerRotationModel *> * __UIViewControllerDefaultRotationClasses() {
    NSArray <NSString *>*classNames = @[
    @"AVPlayerViewController",
    @"AVFullScreenViewController",
    @"AVFullScreenPlaybackControlsViewController",
    @"WebFullScreenVideoRootViewController",
    @"UISnapshotModalViewController",
    ];
    NSMutableArray <UIViewControllerRotationModel *> * result = [NSMutableArray arrayWithCapacity:classNames.count];
    [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:[[[[UIViewControllerRotationModel alloc]
                             initWithClass:className
                             containsSubClass:YES]
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
