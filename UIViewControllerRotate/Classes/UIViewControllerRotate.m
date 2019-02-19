//
//  UIViewController+Rotation.m
//
//  Created by 赵国庆 on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import "UIViewControllerRotate.h"
#import <objc/runtime.h>
#import <RSSwizzle/RSSwizzle.h>
@interface UIApplication (Rotation)
+ (BOOL)__UIApplicationRotation__defaultShouldAutorotate;
+ (UIInterfaceOrientationMask)__UIApplicationRotation__defaultSupportedInterfaceOrientations;
+ (UIInterfaceOrientation)__UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation;
+ (UIStatusBarStyle)__UIApplicationRotation__defaultPreferredStatusBarStyle;
+ (BOOL)__UIApplicationRotation__defaultPrefersStatusBarHidden;
@end

@interface UIViewController ()
@property (nonatomic, assign) BOOL rotation_isDissmissing;
@property (nonatomic, copy) void(^rotation_viewWillAppearBlock)(void);
- (void)rotation_forceToOrientation:(UIInterfaceOrientation)orientation;
@end

@interface InterfaceOrientationController : UIViewController
@property (nonatomic, assign) UIDeviceOrientation orientation;
- (instancetype)initWithRotation:(UIDeviceOrientation)orientation;
@end
@implementation InterfaceOrientationController

- (instancetype)initWithRotation:(UIDeviceOrientation)orientation {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _orientation = orientation;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return true;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self rotation_forceToOrientation:_orientation];
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    switch (_orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            return UIInterfaceOrientationMaskPortrait;
        case UIDeviceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeLeft;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return (UIInterfaceOrientation)_orientation;
}

@end

@interface UIViewControllerRotationModel ()
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSNumber *shouldAutorotate; // BOOL
@property (nonatomic, copy) NSNumber *supportedInterfaceOrientations; // NSUInteger UIInterfaceOrientationMask
@property (nonatomic, copy) NSNumber *preferredInterfaceOrientationForPresentation; // NSInteger UIInterfaceOrientation
@property (nonatomic, copy) NSNumber *preferredStatusBarStyle; // NSInteger UIStatusBarStyle
@property (nonatomic, copy) NSNumber *prefersStatusBarHidden; //BOOL
@end

@implementation UIViewControllerRotationModel

- (id)init {
    NSAssert(false, @"请使用默认初始化方法: - (instancetype)initWithClass:(NSString *)cls");
    return nil;
}

- (instancetype)initWithClass:(NSString *)cls {
    return [self initWithClass:cls
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:nil];
}

- (instancetype)configShouldAutorotate:(BOOL)shouldAutorotate {
    _shouldAutorotate = @(shouldAutorotate);
    return self;
}

- (instancetype)configSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    _supportedInterfaceOrientations = @(supportedInterfaceOrientations);
    return self;
}

- (instancetype)configPrefersStatusBarHidden:(UIInterfaceOrientation)prefersStatusBarHidden {
    _prefersStatusBarHidden = @(prefersStatusBarHidden);
    return self;
}

- (instancetype)configPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle {
    _preferredStatusBarStyle = @(preferredStatusBarStyle);
    return self;
}

- (instancetype)configPreferredInterfaceOrientationForPresentation:(BOOL)preferredInterfaceOrientationForPresentation {
    _preferredInterfaceOrientationForPresentation = @(preferredInterfaceOrientationForPresentation);
    return self;
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

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[UIViewControllerRotationModel allocWithZone:zone]
            initWithClass:self.cls
            shouldAutorotate:self.shouldAutorotate
            supportedInterfaceOrientations:self.supportedInterfaceOrientations
            preferredInterfaceOrientationForPresentation:self.preferredInterfaceOrientationForPresentation
            preferredStatusBarStyle:self.preferredStatusBarStyle
            prefersStatusBarHidden:self.prefersStatusBarHidden];
}

- (NSString *)description {
    if (!_shouldAutorotate && !_supportedInterfaceOrientations &&
        !_preferredInterfaceOrientationForPresentation && !_preferredStatusBarStyle &&
        !_prefersStatusBarHidden) {
        return [NSString stringWithFormat:@"Class<%@> is Default", _cls];
    }
    NSMutableString *string = [NSMutableString stringWithFormat:@"Class<%@>: {", _cls];
    if (_shouldAutorotate) {
        [string appendFormat:@"\n shouldAutorotate: %@", stringForBool([_shouldAutorotate boolValue])];
    }
    if (_supportedInterfaceOrientations) {
        [string appendFormat:@"\n   supportedInterfaceOrientations: %@", stringForInterfaceOrientationMask([_supportedInterfaceOrientations unsignedIntegerValue])];
    }
    if (_preferredInterfaceOrientationForPresentation) {
        [string appendFormat:@"\n   preferredInterfaceOrientationForPresentation: %@", stringForInterfaceOrientation([_preferredInterfaceOrientationForPresentation integerValue])];
    }
    if (_preferredStatusBarStyle) {
        [string appendFormat:@"\n   preferredStatusBarStyle: %@", stringForBarStyle([_preferredStatusBarStyle integerValue])];
    }
    if (_prefersStatusBarHidden) {
        [string appendFormat:@"\n   prefersStatusBarHidden: %@", stringForBool([_prefersStatusBarHidden boolValue])];
    }
    [string appendFormat:@"\n}"];
    return string;
}

- (NSString *)debugDescription {
    return self.description;
}

static NSString *stringForBool(BOOL val) {
    return val ? @"true" : @"false";
}

static NSString *stringForInterfaceOrientationMask(UIInterfaceOrientationMask mask) {
    switch (mask) {
        case UIInterfaceOrientationMaskPortrait:
            return @"MaskPortrait";
        case UIInterfaceOrientationMaskLandscapeLeft:
            return @"MaskLandscapeLeft";
        case UIInterfaceOrientationMaskLandscapeRight:
            return @"MaskLandscapeRight";
        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return @"MaskPortraitUpsideDown";
        case UIInterfaceOrientationMaskLandscape:
            return @"MaskLandscape";
        case UIInterfaceOrientationMaskAll:
            return @"MaskAll";
        case UIInterfaceOrientationMaskAllButUpsideDown:
            return @"MaskAllButUpsideDown";
        default:
            return @"Unknown";
    }
}

static NSString *stringForInterfaceOrientation(UIInterfaceOrientation orientation) {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
        case UIInterfaceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"LandscapeRight";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIInterfaceOrientationUnknown:
        default:
            return @"Unknown";
    }
}

static NSString *stringForBarStyle(UIStatusBarStyle style) {
    switch (style) {
        case UIStatusBarStyleDefault:
            return @"Default";
        case UIStatusBarStyleLightContent:
            return @"LightContent";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case UIStatusBarStyleBlackOpaque:
            return @"BlackOpaque";
#pragma clang diagnostic pop
        default:
            return @"Unknown";
    }
}

@end


@implementation UIViewController (Rotate)

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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self rotation_hook_present];
        [self rotation_hook_dismiss];
        [self rotation_hook_viewWillAppear];
    });
}

/*
 hook 这个方法的目的是解决这个bug:
 A正向 B向左/向右, B C 方向相反
 A push B,
 B pop  A,
 A present C,
 结果: C 的方向与B一样了
 */
+ (void)rotation_hook_present {
    RSSwizzleInstanceMethod(UIViewController.class,
                            @selector(presentViewController:animated:completion:),
                            RSSWReturnType(void),
                            RSSWArguments(UIViewController *viewControllerToPresent, BOOL flag, void (^__nullable completion)(void)),
                            RSSWReplacement({
        UIInterfaceOrientation ori = [self rotation_fix_preferredInterfaceOrientationForPresentation];
        [self rotation_forceToOrientation:ori];
        RSSWCallOriginal(viewControllerToPresent, flag, completion);
    }), RSSwizzleModeAlways, NULL)
}


/*
 hook 这个方法的目的是解决这个bug:
 A B 方向不同
 A present B,
 B dismiss A,
 结果: B -> A 一刻 A 的 presentedViewController 并不是 nil
 导致: 下方的 rotation_findTopViewController 读取错误
 */
+ (void)rotation_hook_dismiss {
    RSSwizzleInstanceMethod(UIViewController.class,
                            @selector(dismissViewControllerAnimated:completion:),
                            RSSWReturnType(void),
                            RSSWArguments(BOOL flag, void (^__nullable completion)(void)),
                            RSSWReplacement({
        __weak __typeof(self) weak_self = self;
        [self setRotation_isDissmissing:true];
        RSSWCallOriginal(flag, ^{
            if (weak_self) {
                [weak_self setRotation_isDissmissing:false];
            }
            if (completion) {
                completion();
            }
        });
    }), RSSwizzleModeAlways, NULL)
}

+ (void)rotation_hook_viewWillAppear {
    RSSwizzleInstanceMethod(UIViewController.class,
                            @selector(viewWillAppear:),
                            RSSWReturnType(void),
                            RSSWArguments(BOOL animated),
                            RSSWReplacement({
        RSSWCallOriginal(animated);
        if ([self rotation_viewWillAppearBlock]) {
            [self rotation_viewWillAppearBlock]();
        }
    }), RSSwizzleModeAlways, NULL)
}

/*
 为什么每次设置orientation的时候都先设置为UnKnown？
 因为在视图B回到视图A时，如果当时设备方向已经是Portrait，再设置成Portrait会不起作用(直接return)。
 */
- (void)rotation_forceToDeviceOrientation:(UIInterfaceOrientation)orientation {
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

- (void)rotation_forceToOrientation:(UIInterfaceOrientation)orientation {
    [self rotation_forceToDeviceOrientation:orientation];
}

// 有一些 系统内部类, 无法重写, 这里就给出一个列表来进行修改
static NSMutableDictionary <NSString *,UIViewControllerRotationModel *>* _rotation_preferenceRotateInternalClassModel;
+ (NSMutableDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rotation_preferenceRotateInternalClassModel = [NSMutableDictionary dictionary];
        NSArray <NSString *>*classNames = @[@"AVFullScreenViewController",
                                            @"AVPlayerViewController",
                                            @"AVFullScreenViewController",
                                            @"AVFullScreenPlaybackControlsViewController",
                                            @"WebFullScreenVideoRootViewController"];
        [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
            [_rotation_preferenceRotateInternalClassModel setObject:[[[[UIViewControllerRotationModel alloc]
                                                                       initWithClass:className]
                                                                      configShouldAutorotate:true]
                                                                     configSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll] forKey:className];
        }];
    });
    return _rotation_preferenceRotateInternalClassModel;
}

+ (void)registerClasses:(NSArray<UIViewControllerRotationModel *> *)models {
    for (UIViewControllerRotationModel *model in models) {
        if (NSClassFromString(model.cls)) {
            [self.rotation_preferenceRotateInternalClassModel setObject:model forKey:model.cls];
        }
    }
}

+ (NSArray <UIViewControllerRotationModel *> *)registedClasses {
    return [[NSArray alloc] initWithArray:self.rotation_preferenceRotateInternalClassModel.allValues copyItems:true];
}

+ (void)removeClasses:(NSArray<NSString *> *)classes {
    [self.rotation_preferenceRotateInternalClassModel removeObjectsForKeys:classes];
}

- (NSMutableDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    return self.class.rotation_preferenceRotateInternalClassModel;
}

/**
 * 默认所有都不支持转屏,如需个别页面支持除竖屏外的其他方向，请在viewController重写这三个方法
 */
- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultShouldAutorotate] : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
}

/// 此方法只针对 present 出来的controller 管用, 在push 的时候不起作用
/// 所以在下边UINavigationController 处 做了处理
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIInterfaceOrientation)rotation_fix_preferredInterfaceOrientationForPresentation {
    return self.shouldAutorotate ? self.preferredInterfaceOrientationForPresentation : [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
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
@implementation UINavigationController (Rotate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self rotation_hook_push];
        
        /*
         系统调用这两个方法 没有调用 shouldAutorotate 和 supportedInterfaceOrientations
         导致 界面没有旋转回正确位置
         */
        [self rotation_hook_pop];
        [self rotation_hook_popToRoot];
    });
}

+ (void)rotation_hook_push {
    RSSwizzleInstanceMethod(UINavigationController.class,
                            @selector(pushViewController:animated:),
                            RSSWReturnType(void),
                            RSSWArguments(UIViewController *viewController, BOOL animated),
                            RSSWReplacement({
        UIViewController *fromViewController = [self viewControllers].lastObject;
        UIViewController *toViewController = viewController;
        [self rotation_setupPrientationWithFromVC:fromViewController toVC:toViewController];
        RSSWCallOriginal(viewController, animated);
    }), RSSwizzleModeAlways, NULL)
}

/*
 在系统调用下列两个方法的时候 只有两个相邻的ViewController之间POP才会修复旋转
 所以在这种情况下 在POP超过两个界面的情况下 插入一个中间界面与想要跳转的界面方向相同 即可解决
 */
+ (void)rotation_hook_pop {
    RSSwizzleInstanceMethod(UINavigationController.class,
                            @selector(popToViewController:animated:),
                            RSSWReturnType(NSArray<UIViewController *> *),
                            RSSWArguments(UIViewController *viewController, BOOL animated),
                            RSSWReplacement({
        
        if ([self viewControllers].count <= 2) { return RSSWCallOriginal(viewController, animated); }
        UIViewController *fromViewController = [self viewControllers].lastObject;
        UIViewController *toViewController = viewController;
        if ([toViewController isKindOfClass:InterfaceOrientationController.class]) { return RSSWCallOriginal(viewController, animated); }
        if (fromViewController == toViewController) { return RSSWCallOriginal(viewController, animated); }
        if ([fromViewController rotation_fix_preferredInterfaceOrientationForPresentation] == [toViewController rotation_fix_preferredInterfaceOrientationForPresentation]) {
            return RSSWCallOriginal(viewController, animated);
        }
//        if ([toViewController rotation_fix_preferredInterfaceOrientationForPresentation] != [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation]) {
//            return RSSWCallOriginal(viewController, animated);
//        }
        NSInteger idx = [[self viewControllers] indexOfObject:viewController];
        if (idx == NSNotFound) { return RSSWCallOriginal(viewController, animated); }
        if (idx == [self viewControllers].count - 2) { return @[[self popViewControllerAnimated:animated]]; };
        NSMutableArray<UIViewController *> * vcs = [[self viewControllers] mutableCopy];
        UIViewController *fixController = [[InterfaceOrientationController alloc] initWithRotation:[toViewController rotation_fix_preferredInterfaceOrientationForPresentation]];
        [vcs insertObject:fixController atIndex:vcs.count - 1];
        [self setViewControllers:vcs];
        return [@[[self popViewControllerAnimated:true]] arrayByAddingObjectsFromArray:RSSWCallOriginal(viewController, false)];
    }), RSSwizzleModeAlways, NULL)
}

+ (void)rotation_hook_popToRoot {
    RSSwizzleInstanceMethod(UINavigationController.class,
                            @selector(popToRootViewControllerAnimated:),
                            RSSWReturnType(NSArray<UIViewController *> *),
                            RSSWArguments(BOOL animated),
                            RSSWReplacement({
        if ([self viewControllers].count <= 2) { return RSSWCallOriginal(animated); }
        UIViewController *fromViewController = [self viewControllers].lastObject;
        UIViewController *toViewController = [self viewControllers].firstObject;
        if ([toViewController isKindOfClass:InterfaceOrientationController.class]) { return RSSWCallOriginal(animated); }
        if ([fromViewController rotation_fix_preferredInterfaceOrientationForPresentation] == [toViewController rotation_fix_preferredInterfaceOrientationForPresentation]) {
            return RSSWCallOriginal(animated);
        }
//        if ([toViewController rotation_fix_preferredInterfaceOrientationForPresentation] != [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation]) {
//            return RSSWCallOriginal(animated);
//        }
        NSMutableArray<UIViewController *> * vcs = [[self viewControllers] mutableCopy];
        UIViewController *fixController = [[InterfaceOrientationController alloc] initWithRotation:[toViewController rotation_fix_preferredInterfaceOrientationForPresentation]];
        [vcs insertObject:fixController atIndex:vcs.count - 1];
        [self setViewControllers:vcs];
        return [@[[self popViewControllerAnimated:true]] arrayByAddingObjectsFromArray:RSSWCallOriginal(false)];
    }), RSSwizzleModeAlways, NULL)
}

- (void)rotation_setupPrientationWithFromVC:(UIViewController *)fromViewController toVC:(UIViewController *)toViewController {
    if (fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation != toViewController.rotation_fix_preferredInterfaceOrientationForPresentation) {
        __weak UIViewController * weak_toController = toViewController;
        toViewController.rotation_viewWillAppearBlock = ^{
            if (weak_toController == nil) { return; }
            UIInterfaceOrientation ori = weak_toController.rotation_fix_preferredInterfaceOrientationForPresentation;
            [self rotation_forceToOrientation:ori];
        };
    } else {
        toViewController.rotation_viewWillAppearBlock = nil;
    }
}

- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultShouldAutorotate] : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
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

@implementation UITabBarController (Rotate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self rotation_hook_setSelectedIndex];
        [self rotation_hook_setSelectedViewController];
    });
}

+ (void)rotation_hook_setSelectedIndex {
    RSSwizzleInstanceMethod(UITabBarController.class,
                            @selector(setSelectedIndex:),
                            RSSWReturnType(void),
                            RSSWArguments(NSUInteger selectedIndex),
                            RSSWReplacement({
        RSSWCallOriginal(selectedIndex); 
        UIViewController *vc = [self selectedViewController];
        UIInterfaceOrientation ori = vc.rotation_fix_preferredInterfaceOrientationForPresentation;
        [self rotation_forceToOrientation:ori];
    }), RSSwizzleModeAlways, NULL)
}

+ (void)rotation_hook_setSelectedViewController {
    RSSwizzleInstanceMethod(UITabBarController.class,
                            @selector(setSelectedViewController:),
                            RSSWReturnType(void),
                            RSSWArguments(__kindof UIViewController *selectedViewController),
                            RSSWReplacement({
        RSSWCallOriginal(selectedViewController);
        UIViewController *vc = [self selectedViewController];
        UIInterfaceOrientation ori = vc.rotation_fix_preferredInterfaceOrientationForPresentation;
        [self rotation_forceToOrientation:ori];
    }), RSSwizzleModeAlways, NULL)
}

- (BOOL)shouldAutorotate {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.shouldAutorotate) return preference.shouldAutorotate.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultShouldAutorotate] : topVC.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.supportedInterfaceOrientations) return preference.supportedInterfaceOrientations.unsignedIntegerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredInterfaceOrientationForPresentation) return preference.preferredInterfaceOrientationForPresentation.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.preferredStatusBarStyle) return preference.preferredStatusBarStyle.integerValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVC = self.rotation_findTopViewController;
    UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[NSStringFromClass(topVC.class)];
    if (preference && preference.prefersStatusBarHidden) return preference.prefersStatusBarHidden.boolValue;
    return topVC == self ? [UIApplication __UIApplicationRotation__defaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
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

@implementation UIApplication (Rotate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSSwizzleInstanceMethod(UIApplication.class,
                                @selector(setDelegate:),
                                RSSWReturnType(void),
                                RSSWArguments(id<UIApplicationDelegate> delegate),
                                RSSWReplacement({
            [self hook_setDelegate:delegate];
            RSSWCallOriginal(delegate);
        }), RSSwizzleModeAlways, NULL)
    });
}

- (void)hook_setDelegate:(id<UIApplicationDelegate>)delegate {
    SEL selector = @selector(application:supportedInterfaceOrientationsForWindow:);
    struct objc_method_description protocol_del = protocol_getMethodDescription(@protocol(UIApplicationDelegate), selector, false, true);
    Method method = class_getInstanceMethod([delegate class], protocol_del.name);
    if (method) {
        RSSwizzleInstanceMethod([delegate class],
                                protocol_del.name,
                                RSSWReturnType(UIInterfaceOrientationMask),
                                RSSWArguments(UIApplication *application, UIWindow *window),
                                RSSWReplacement({
            if (window.rootViewController.rotation_findTopViewController) {
                return window.rootViewController.rotation_findTopViewController.supportedInterfaceOrientations;
            } else {
                return [UIApplication __UIApplicationRotation__defaultSupportedInterfaceOrientations];
            }
        }), RSSwizzleModeAlways, NULL)
    } else {
        id block = ^UIInterfaceOrientationMask(__unsafe_unretained id self, UIApplication *application, UIWindow *window) {
            if (window.rootViewController.rotation_findTopViewController) {
                return window.rootViewController.rotation_findTopViewController.supportedInterfaceOrientations;
            } else {
                return [UIApplication __UIApplicationRotation__defaultSupportedInterfaceOrientations];
            }
        };
        IMP newIMP = imp_implementationWithBlock(block);
        class_addMethod([delegate class], protocol_del.name, newIMP, protocol_del.types);
    }
}

+ (BOOL)__UIApplicationRotation__defaultShouldAutorotate {
    if ([self respondsToSelector:@selector(defaultShouldAutorotate)]) {
        return [self defaultShouldAutorotate];
    } else {
        return YES;
    }
}

+ (UIInterfaceOrientationMask)__UIApplicationRotation__defaultSupportedInterfaceOrientations {
    if ([self respondsToSelector:@selector(defaultSupportedInterfaceOrientations)]) {
        return [self defaultSupportedInterfaceOrientations];
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

+ (UIInterfaceOrientation)__UIApplicationRotation__defaultPreferredInterfaceOrientationForPresentation {
    if ([self respondsToSelector:@selector(defaultPreferredInterfaceOrientationForPresentation)]) {
        return [self defaultPreferredInterfaceOrientationForPresentation];
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

+ (UIStatusBarStyle)__UIApplicationRotation__defaultPreferredStatusBarStyle {
    if ([self respondsToSelector:@selector(defaultPreferredStatusBarStyle)]) {
        return [self defaultPreferredStatusBarStyle];
    } else {
        return UIStatusBarStyleDefault;
    }
}

+ (BOOL)__UIApplicationRotation__defaultPrefersStatusBarHidden {
    if ([self respondsToSelector:@selector(defaultPrefersStatusBarHidden)]) {
        return [self defaultPrefersStatusBarHidden];
    } else {
        return NO;
    }
}
@end
