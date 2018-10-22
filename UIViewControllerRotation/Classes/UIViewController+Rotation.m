//
//  UIViewController+Rotation.h
//  wmICIOS
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import "UIViewController+Rotation.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void _exchangeClassInstanceMethod(Class cls, SEL s1, SEL s2) {
    Method originalMethod = class_getInstanceMethod(cls, s1);
    Method swizzledMethod = class_getInstanceMethod(cls, s2);
    if (class_addMethod(cls, s1, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(cls, s2, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIViewControllerRotationModel ()
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSNumber *shouldAutorotate; // BOOL
@property (nonatomic, copy) NSNumber *supportedInterfaceOrientations; // NSUInteger UIInterfaceOrientationMask
@property (nonatomic, copy) NSNumber *preferredInterfaceOrientationForPresentation; // NSInteger UIInterfaceOrientation
@property (nonatomic, copy) NSNumber *preferredStatusBarStyle; // NSInteger UIStatusBarStyle
@property (nonatomic, copy) NSNumber *prefersStatusBarHidden; //BOOL
@end

@implementation UIViewControllerRotationModel

- (void)conigShouldAutorotate:(BOOL)shouldAutorotate {
    _shouldAutorotate = @(shouldAutorotate);
}

- (void)conigSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    _supportedInterfaceOrientations = @(supportedInterfaceOrientations);
}

- (void)conigPrefersStatusBarHidden:(UIInterfaceOrientation)prefersStatusBarHidden {
    _prefersStatusBarHidden = @(prefersStatusBarHidden);
}

- (void)conigPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle {
    _preferredStatusBarStyle = @(preferredStatusBarStyle);
}

- (void)conigPreferredInterfaceOrientationForPresentation:(BOOL)preferredInterfaceOrientationForPresentation {
    _preferredInterfaceOrientationForPresentation = @(preferredInterfaceOrientationForPresentation);
}

- (instancetype)initWithDefault:(NSString *)cls {
    return [self initWithClass:cls
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:nil];
}

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self initWithClass:cls
              shouldAutorotate:@(shouldAutorotate)
supportedInterfaceOrientations:@(supportedInterfaceOrientations)
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:nil];
}

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self initWithClass:cls
              shouldAutorotate:@(shouldAutorotate)
supportedInterfaceOrientations:@(supportedInterfaceOrientations)
preferredInterfaceOrientationForPresentation:@(preferredInterfaceOrientationForPresentation)
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:nil];
}

- (instancetype)initWithCls:(NSString *)cls
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden {
    return [self initWithClass:cls
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:@(preferredStatusBarStyle)
        prefersStatusBarHidden:@(prefersStatusBarHidden)];
}

- (instancetype)initWithCls:(NSString *)cls
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle {
    return [self initWithClass:cls
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:@(preferredStatusBarStyle)
        prefersStatusBarHidden:nil];
}

- (instancetype)initWithCls:(NSString *)cls
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden {
    return [self initWithClass:cls
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:@(prefersStatusBarHidden)];
}

- (instancetype)initWithCls:(NSString *)cls
           shouldAutorotate: (BOOL)shouldAutorotate
supportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
    preferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
     prefersStatusBarHidden:(BOOL)prefersStatusBarHidden {
    return [self initWithClass:cls
              shouldAutorotate:@(shouldAutorotate)
supportedInterfaceOrientations:@(supportedInterfaceOrientations)
preferredInterfaceOrientationForPresentation:@(preferredInterfaceOrientationForPresentation)
       preferredStatusBarStyle:@(preferredStatusBarStyle)
        prefersStatusBarHidden:@(prefersStatusBarHidden)];
}


- (instancetype)initWithClass:(NSString *)cls
           shouldAutorotate: (NSNumber *)shouldAutorotate
supportedInterfaceOrientations:(NSNumber *)supportedInterfaceOrientations
preferredInterfaceOrientationForPresentation:(NSNumber *)preferredInterfaceOrientationForPresentation
    preferredStatusBarStyle:(NSNumber *)preferredStatusBarStyle
     prefersStatusBarHidden:(NSNumber *)prefersStatusBarHidden {
    self = [super init];
    if (self) {
        _cls = cls;
        _shouldAutorotate = shouldAutorotate;
        _supportedInterfaceOrientations = supportedInterfaceOrientations;
        _preferredInterfaceOrientationForPresentation = preferredInterfaceOrientationForPresentation;
        _preferredStatusBarStyle = preferredStatusBarStyle;
        _prefersStatusBarHidden = prefersStatusBarHidden;
    }
    return self;
}
@end

@interface UIViewController ()
@property (nonatomic, assign) BOOL rotation_isDissmissing;
@property (nonatomic, copy) void(^rotation_viewWillAppearBlock)(void);
@property (nonatomic, copy) void(^rotation_viewWillDisappearBlock)(void);
@end

@implementation UIViewController (Rotation)

static void *rotation_isDissmissingKey;
- (BOOL)rotation_isDissmissing {
    return [objc_getAssociatedObject(self, &rotation_isDissmissingKey) boolValue];
}

- (void)setRotation_isDissmissing:(BOOL)rotation_isDissmissing {
    objc_setAssociatedObject(self, &rotation_isDissmissingKey, @(rotation_isDissmissing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void *rotation_viewWillAppearBlockKey;
- (void (^)(void))rotation_viewWillAppearBlock {
    return objc_getAssociatedObject(self, &rotation_viewWillAppearBlockKey);
}

- (void)setRotation_viewWillAppearBlock:(void (^)(void))rotation_viewWillAppearBlock {
    objc_setAssociatedObject(self, &rotation_viewWillAppearBlockKey, (id)rotation_viewWillAppearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void *rotation_viewWillDisappearBlockKey;
- (void (^)(void))rotation_viewWillDisappearBlock {
    return objc_getAssociatedObject(self, &rotation_viewWillDisappearBlockKey);
}

- (void)setRotation_viewWillDisappearBlock:(void (^)(void))rotation_viewWillDisappearBlock {
    objc_setAssociatedObject(self, &rotation_viewWillDisappearBlockKey, (id)rotation_viewWillDisappearBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exchangeClassInstanceMethod(UIViewController.class, @selector(dismissViewControllerAnimated:completion:), @selector(rotation_hook_dismissViewControllerAnimated:completion:));
        _exchangeClassInstanceMethod(UIViewController.class, @selector(presentViewController:animated:completion:), @selector(rotation_hook_presentViewController:animated:completion:));
        _exchangeClassInstanceMethod(UIViewController.class, @selector(viewWillAppear:), @selector(rotation_hook_viewWillAppear:));
        _exchangeClassInstanceMethod(UIViewController.class, @selector(viewWillDisappear:), @selector(rotation_hook_viewWillDisappear:));
        
        
        UIViewControllerRotationModel *AVFullScreenViewController = [[UIViewControllerRotationModel alloc] initWithCls:@"AVFullScreenViewController"
                                                                                                      shouldAutorotate:YES
                                                                                        supportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
        UIViewControllerRotationModel *UIAlertController = [[UIViewControllerRotationModel alloc] initWithCls:@"UIAlertController"
                                                                                            shouldAutorotate:YES
                                                                               supportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
        [self registerClass:@[AVFullScreenViewController, UIAlertController]];
    });
}

- (void)rotation_hook_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    __weak __typeof(self) weak_self = self;
    self.rotation_isDissmissing = true;
    [self rotation_hook_dismissViewControllerAnimated:flag completion:^{
        weak_self.rotation_isDissmissing = false;
        if (completion) {
            completion();
        }
    }];
}

- (void)rotation_hook_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self rotation_hook_presentViewController:viewControllerToPresent animated:flag completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)rotation_hook_viewWillAppear:(BOOL)animated {
    [self rotation_hook_viewWillAppear: animated];
    if (self.rotation_viewWillAppearBlock) {
        self.rotation_viewWillAppearBlock();
    }
}

- (void)rotation_hook_viewWillDisappear:(BOOL)animated {
    [self rotation_hook_viewWillDisappear: animated];
    if (self.rotation_viewWillDisappearBlock) self.rotation_viewWillDisappearBlock();
}

/*
 为什么每次设置orientation的时候都先设置为UnKnown？
 因为在视图B回到视图A时，如果当时设备方向已经是Portrait，再设置成Portrait会不起作用(直接return)。
 */
- (void)rotation_forceToOrientation:(UIDeviceOrientation)orientation {
    NSLog(@"orientation: %ld", orientation);
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

// 有一些 系统内部类, 无法重写, 这里就给出一个列表来进行修改
static NSMutableDictionary <NSString *,UIViewControllerRotationModel *>* _rotation_preferenceRotateInternalClassModel;
+ (NSMutableDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rotation_preferenceRotateInternalClassModel = [NSMutableDictionary dictionary];
    });
    return _rotation_preferenceRotateInternalClassModel;
}

+ (void)registerClass:(NSArray<UIViewControllerRotationModel *> *)models {
    for (UIViewControllerRotationModel *model in models) {
        if (NSClassFromString(model.cls)) {
            [[self rotation_preferenceRotateInternalClassModel] setObject:model forKey:model.cls];
        }
    }
}

- (NSMutableDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    return [[self class] rotation_preferenceRotateInternalClassModel];
}

/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

/// 此方法只针对 present 出来的controller 管用, 在push 的时候不起作用
/// 所以在下边UINavigationController 处 做了处理
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)rotation_findTopViewController {
    UIViewController *result;
    if ([self isKindOfClass:UINavigationController.class]) {
        result = ((UINavigationController *)self).topViewController.rotation_findTopViewController;
    } else if ([self isKindOfClass:UITabBarController.class]) {
        result = ((UITabBarController *)self).selectedViewController.rotation_findTopViewController;
    } else {
        /// 在系统进行跳转的时候 会有一个中间态 这个中间态不需要处理
        NSArray <NSString *>* excludeCls = @[@"UISnapshotModalViewController"];
        /// 当前控制器 模态的Controller
        UIViewController *presentedVC = self.presentedViewController;
        if (presentedVC != nil && ![excludeCls containsObject:NSStringFromClass(presentedVC.class)]) {
            result = self.presentedViewController.rotation_findTopViewController;
        } else if ([excludeCls containsObject:NSStringFromClass(self.class)]) {
            /// 模态出当前控制器的Controller
            result = self.presentingViewController;
        } else {
            result = self;
        }
    }
    result = result ?: self;
    if (result.rotation_isDissmissing) {
        /// B dismiss A 的时候
        /// A 的 presentedViewController 并不是 nil
        /// 这会导致读取错误, 所以要在dismiss的时候向前读取controller
        result = result.rotation_findLastNotDismissController;
    }
    return result;
}

- (UIViewController *)rotation_findLastNotDismissController {
    NSArray <NSString *>* excludeCls = @[@"UISnapshotModalViewController"];
    UIViewController *result = self;
    while (result.rotation_isDissmissing && ![excludeCls containsObject:NSStringFromClass(result.class)]) {
        result = self.presentingViewController;
    }
    return result;
}
@end

/*
 在这里 UINavigationController和UITabBarController 必须重写
 因为当 默认的UINavigationController和UITabBarController 创建的时候内部也重写了这些方法 这里要把它再重写掉
 优先级为 UIViewController < UIViewController(Category) < UINavigationController/UITabBarController < UINavigationController(Category)/UITabBarController(Category) < 自定义UINavigationController/UITabBarController
 */
@implementation UINavigationController (Rotation)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exchangeClassInstanceMethod(UINavigationController.class, @selector(pushViewController:animated:), @selector(rotation_hook_pushViewController:animated:));
        /*
         系统调用这两个方法 没有调用 shouldAutorotate 和 supportedInterfaceOrientations
         导致 界面没有旋转回正确位置
         */
        _exchangeClassInstanceMethod(UINavigationController.class, @selector(popToViewController:animated:), @selector(rotation_hook_popToViewController:animated:));
        _exchangeClassInstanceMethod(UINavigationController.class, @selector(popToRootViewControllerAnimated:), @selector(rotation_hook_popToRootViewControllerAnimated:));
    });
}

- (void)rotation_hook_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *fromViewController = self.viewControllers.lastObject;
    UIViewController *toViewController = viewController;
    [self rotation_setupPrientationWithFromVC:fromViewController toVC:toViewController];
    [self rotation_hook_pushViewController: viewController animated: animated];
}

- (NSArray<UIViewController *> *)rotation_hook_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *fromViewController = self.viewControllers.lastObject;
    UIViewController *toViewController = viewController;
    if (self.viewControllers.count <= 2) { return [self rotation_hook_popToViewController:viewController animated:animated]; }
    if (fromViewController == toViewController) { return [self rotation_hook_popToViewController:viewController animated:animated]; }
    NSInteger idx = [self.viewControllers indexOfObject:viewController];
    if (idx == NSNotFound) { return [self rotation_hook_popToViewController:viewController animated:animated]; }
    if (idx == self.viewControllers.count - 2) { return @[[self popViewControllerAnimated:animated]]; };
    NSArray<UIViewController *> * vcs = [self.viewControllers subarrayWithRange:NSMakeRange(idx, self.viewControllers.count - (idx + 1))];
    [self popToViewController:self.viewControllers[idx + 1] animated:animated];
    [self popViewControllerAnimated:false];
    return vcs;
}

- (NSArray<UIViewController *> *)rotation_hook_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) { return [self rotation_hook_popToRootViewControllerAnimated:animated]; }
    if (self.viewControllers.count == 2) { return @[[self popViewControllerAnimated:animated]]; }
    NSArray<UIViewController *> * vcs = [self.viewControllers subarrayWithRange:NSMakeRange(1, self.viewControllers.count - 2)];
    [self popToViewController:self.viewControllers[1] animated:animated];
    [self popViewControllerAnimated:false];
    return vcs;
}

- (void)rotation_setupPrientationWithFromVC:(UIViewController *)fromViewController toVC:(UIViewController *)toViewController {
    if (fromViewController.preferredInterfaceOrientationForPresentation != toViewController.preferredInterfaceOrientationForPresentation) {
        __weak UIViewController * weak_toController = toViewController;
        toViewController.rotation_viewWillAppearBlock = ^{
            if (weak_toController == nil) { return; }
            UIInterfaceOrientation ori = weak_toController.preferredInterfaceOrientationForPresentation;
            switch (ori) {
                case UIInterfaceOrientationUnknown:
                    break;
                case UIInterfaceOrientationPortrait:
                    [self rotation_forceToOrientation:(UIDeviceOrientationPortrait)];
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    [self rotation_forceToOrientation:(UIDeviceOrientationLandscapeLeft)];
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    [self rotation_forceToOrientation:(UIDeviceOrientationLandscapeRight)];
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    [self rotation_forceToOrientation:(UIDeviceOrientationPortraitUpsideDown)];
                    break;
            }
        };
    } else {
        toViewController.rotation_viewWillAppearBlock = nil;
    }
    toViewController.rotation_viewWillDisappearBlock = nil;
}

- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}
@end

@implementation UITabBarController (Rotation)
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? NO : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? UIInterfaceOrientationMaskPortrait : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? UIInterfaceOrientationPortrait : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? UIStatusBarStyleDefault : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? NO : topVC.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    return topVC == self ? nil : topVC;
}
@end

@implementation UIApplication (Rotation)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _exchangeClassInstanceMethod(self.class, @selector(setDelegate:), @selector(hook_setDelegate:));
    });
}

- (void)hook_setDelegate:(id<UIApplicationDelegate>)delegate {
    SEL oldSelector = @selector(application:supportedInterfaceOrientationsForWindow:);
    SEL newSelector = @selector(hook_application:supportedInterfaceOrientationsForWindow:);
    Method oldMethod_del = class_getInstanceMethod([delegate class], oldSelector);
    Method oldMethod_self = class_getInstanceMethod([self class], oldSelector);
    Method newMethod = class_getInstanceMethod([self class], newSelector);
    BOOL isSuccess = class_addMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
    if (isSuccess) {
        class_replaceMethod([delegate class], newSelector, class_getMethodImplementation([self class], oldSelector), method_getTypeEncoding(oldMethod_self));
    } else {
        BOOL isVictory = class_addMethod([delegate class], newSelector, class_getMethodImplementation([delegate class], oldSelector), method_getTypeEncoding(oldMethod_del));
        if (isVictory) {
            class_replaceMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
        }
    }
    [self hook_setDelegate:delegate];
}

- (UIInterfaceOrientationMask)hook_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if (window.rootViewController.rotation_findTopViewController) {
        return window.rootViewController.rotation_findTopViewController.supportedInterfaceOrientations;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end


