//
//  UIViewController+Rotation.m
//
//  Created by kagen on 2018/7/11.
//  Copyright © 2018年 kagen. All rights reserved.
//

#import "UIViewControllerRotate.h"
#import "KZRSSwizzle.h"
#import <objc/runtime.h>
@interface UIApplication (_Rotation)
+ (BOOL)_UIApplicationRotationDefaultShouldAutorotate;
+ (UIInterfaceOrientationMask)_UIApplicationRotationDefaultSupportedInterfaceOrientations;
+ (UIInterfaceOrientation)_UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation;
+ (UIStatusBarStyle)_UIApplicationRotationDefaultPreferredStatusBarStyle;
+ (BOOL)_UIApplicationRotationDefaultPrefersStatusBarHidden;
@end

@interface UIViewController (Rotate)
@property (nonatomic, assign) BOOL rotation_isDissmissing;
@property (nonatomic, copy) void(^rotation_viewWillAppearBlock)(void);

- (UIViewController *)rotation_findTopViewController;
- (UIInterfaceOrientation)rotation_fix_preferredInterfaceOrientationForPresentation;
- (void)rotation_forceToOrientation:(UIInterfaceOrientation)orientation;
@end

@interface UIViewControllerRotateDefault ()
@end

@implementation UIViewControllerRotateDefault

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static UIViewControllerRotateDefault * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[UIViewControllerRotateDefault alloc] initDefaultValues];
    });
    return instance;
}

- (instancetype)init {
    NSAssert(false, @"请使公共初始化方法: + (instancetype)shared;");
    return nil;
}

- (instancetype) initDefaultValues {
    self = [super init];
    if (self) {
        _defaultShouldAutorotate = YES;
        _defaultSupportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        _defaultPreferredInterfaceOrientationForPresentation = UIInterfaceOrientationPortrait;
        _defaultPreferredStatusBarStyle = UIStatusBarStyleDefault;
        _defaultPrefersStatusBarHidden = NO;
        
        [self addObserver:self forKeyPath:@"defaultPrefersStatusBarHidden" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        [self addObserver:self forKeyPath:@"defaultPreferredStatusBarStyle" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        
        [self addObserver:self forKeyPath:@"defaultShouldAutorotate" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        [self addObserver:self forKeyPath:@"defaultSupportedInterfaceOrientations" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        [self addObserver:self forKeyPath:@"defaultPreferredInterfaceOrientationForPresentation" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"defaultPrefersStatusBarHidden"] || [keyPath isEqualToString:@"defaultPreferredStatusBarStyle"]) {
        UIViewController * topViewController = [[[UIApplication sharedApplication] keyWindow].rootViewController rotation_findTopViewController];
        [topViewController setNeedsStatusBarAppearanceUpdate];
    } else if ([keyPath isEqualToString:@"defaultShouldAutorotate"] || [keyPath isEqualToString:@"defaultSupportedInterfaceOrientations"] || [keyPath isEqualToString:@"defaultPreferredInterfaceOrientationForPresentation"]) {
        UIViewController * topViewController = [[[UIApplication sharedApplication] keyWindow].rootViewController rotation_findTopViewController];
        UIInterfaceOrientation ori = topViewController.rotation_fix_preferredInterfaceOrientationForPresentation;
        [topViewController rotation_forceToOrientation:ori];
    }
}

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
@property (nonatomic, assign) BOOL containsSubClass;
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSNumber *shouldAutorotate; // BOOL
@property (nonatomic, copy) NSNumber *supportedInterfaceOrientations; // NSUInteger UIInterfaceOrientationMask
@property (nonatomic, copy) NSNumber *preferredInterfaceOrientationForPresentation; // NSInteger UIInterfaceOrientation
@property (nonatomic, copy) NSNumber *preferredStatusBarStyle; // NSInteger UIStatusBarStyle
@property (nonatomic, copy) NSNumber *prefersStatusBarHidden; //BOOL
@end

@implementation UIViewControllerRotationModel

- (id)init {
    NSAssert(false, @"请使用默认初始化方法: - (instancetype)initWithClass:(NSString *)cls containsSubClass:(BOOL)containsSubClass");
    return nil;
}

- (instancetype)initWithClass:(NSString *)cls containsSubClass:(BOOL)containsSubClass {
    return [self initWithClass:cls
              containsSubClass:containsSubClass
              shouldAutorotate:nil
supportedInterfaceOrientations:nil
preferredInterfaceOrientationForPresentation:nil
       preferredStatusBarStyle:nil
        prefersStatusBarHidden:nil];
}

- (Class)getClass {
    return NSClassFromString(_cls);
}

- (instancetype)configContainsSubClass:(BOOL)containsSubClass {
    _containsSubClass = containsSubClass;
    return self;
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
             containsSubClass:(BOOL)containsSubClass
             shouldAutorotate:(NSNumber *)shouldAutorotate
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
            containsSubClass:self.containsSubClass
            shouldAutorotate:self.shouldAutorotate
            supportedInterfaceOrientations:self.supportedInterfaceOrientations
            preferredInterfaceOrientationForPresentation:self.preferredInterfaceOrientationForPresentation
            preferredStatusBarStyle:self.preferredStatusBarStyle
            prefersStatusBarHidden:self.prefersStatusBarHidden];
}

- (NSNumber *)shouldAutorotate {
    return _shouldAutorotate ?: @([UIApplication _UIApplicationRotationDefaultShouldAutorotate]);
}

- (NSNumber *)supportedInterfaceOrientations {
    return _supportedInterfaceOrientations ?: @([UIApplication _UIApplicationRotationDefaultSupportedInterfaceOrientations]);
}

- (NSNumber *)preferredInterfaceOrientationForPresentation {
    return _preferredInterfaceOrientationForPresentation ?: @([UIApplication _UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation]);
}

- (NSNumber *)preferredStatusBarStyle {
    return _preferredStatusBarStyle ?: @([UIApplication _UIApplicationRotationDefaultPreferredStatusBarStyle]);
}

- (NSNumber *)prefersStatusBarHidden {
    return _prefersStatusBarHidden ?: @([UIApplication _UIApplicationRotationDefaultPrefersStatusBarHidden]);
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"{"];
    [string appendFormat:@"\n   class:                                        %@", _cls];
    [string appendFormat:@"\n   shouldAutorotate:                             %@", stringForBool([[self shouldAutorotate] boolValue])];
    [string appendFormat:@"\n   supportedInterfaceOrientations:               %@", stringForInterfaceOrientationMask([[self supportedInterfaceOrientations] unsignedIntegerValue])];
    [string appendFormat:@"\n   preferredInterfaceOrientationForPresentation: %@", stringForInterfaceOrientation([[self preferredInterfaceOrientationForPresentation] integerValue])];
    [string appendFormat:@"\n   preferredStatusBarStyle:                      %@", stringForBarStyle([[self preferredStatusBarStyle] integerValue])];
    [string appendFormat:@"\n   prefersStatusBarHidden:                       %@", stringForBool([[self prefersStatusBarHidden] boolValue])];
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

static void *rotation_isPresentingKey;
- (BOOL)rotation_isPresenting {
    return [objc_getAssociatedObject(self, &rotation_isPresentingKey) boolValue];
}

- (void)setRotation_isPresenting:(BOOL)rotation_isPresenting {
    objc_setAssociatedObject(self, &rotation_isPresentingKey, @(rotation_isPresenting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        [self rotation_hook_shouldAutorotate];
        [self rotation_hook_supportedInterfaceOrientations];
        [self rotation_hook_preferredInterfaceOrientationForPresentation];
        [self rotation_hook_preferredStatusBarStyle];
        [self rotation_hook_prefersStatusBarHidden];
        [self rotation_hook_childViewControllerForStatusBarStyle];
        [self rotation_hook_childViewControllerForStatusBarHidden];
        
        [self rotation_hook_viewWillAppear];
    });
}

+ (void)rotation_hook_viewWillAppear {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(viewWillAppear:)
     inClass:UIViewController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         void (*originalImplementation_)(__unsafe_unretained id, SEL, BOOL animated);
         SEL selector_ = @selector(viewWillAppear:);
         return ^void (__unsafe_unretained id self, BOOL animated) {
             KZRSSWCallOriginal(animated);
             if ([self rotation_viewWillAppearBlock]) {
                 [self rotation_viewWillAppearBlock]();
             }
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

/*
 为什么每次设置orientation的时候都先设置为UnKnown？
 因为在视图B回到视图A时，如果当时设备方向已经是Portrait，再设置成Portrait会不起作用(直接return)。
 */
- (void)rotation_forceToDeviceOrientation:(UIDeviceOrientation)orientation {
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

- (void)rotation_forceToOrientation:(UIInterfaceOrientation)orientation {
    [self rotation_forceToDeviceOrientation:(UIDeviceOrientation)orientation];
}

// 有一些 系统内部类, 无法重写, 这里就给出一个列表来进行修改
static NSMutableDictionary <NSString *,UIViewControllerRotationModel *>* _rotation_preferenceRotateInternalClassModel;
+ (NSMutableDictionary <NSString *,UIViewControllerRotationModel *>*)rotation_preferenceRotateInternalClassModel {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rotation_preferenceRotateInternalClassModel = [NSMutableDictionary dictionary];
        [__UIViewControllerDefaultRotationClasses() enumerateObjectsUsingBlock:^(UIViewControllerRotationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_rotation_preferenceRotateInternalClassModel setObject:obj forKey:obj.cls];
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

- (nullable UIViewControllerRotationModel *)rotation_getPreferenceInternalClassModel:(Class)class {
    NSString *className = NSStringFromClass(class);
    __block UIViewControllerRotationModel *preference = self.rotation_preferenceRotateInternalClassModel[className];
    if (preference) { return preference; }
    [self.rotation_preferenceRotateInternalClassModel enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewControllerRotationModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.containsSubClass) {
            if ([class isKindOfClass:obj.getClass]) {
                preference = obj;
                *stop = true;
            }
        } else {
            if ([class isMemberOfClass:obj.getClass]) {
                preference = obj;
                *stop = true;
            }
        }
    }];
    return preference;
}

+ (void)rotation_hook_shouldAutorotate {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(shouldAutorotate)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController *self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.shouldAutorotate.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultShouldAutorotate] : topVC.shouldAutorotate;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_supportedInterfaceOrientations {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(supportedInterfaceOrientations)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientationMask (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.supportedInterfaceOrientations.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

/// 此方法只针对 present 出来的controller 管用, 在push 的时候不起作用
/// 所以在下边UINavigationController 处 做了处理
+ (void)rotation_hook_preferredInterfaceOrientationForPresentation {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredInterfaceOrientationForPresentation)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientation (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredInterfaceOrientationForPresentation.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_preferredStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredStatusBarStyle)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIStatusBarStyle (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredStatusBarStyle.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_prefersStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(prefersStatusBarHidden)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.prefersStatusBarHidden.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarStyle)
     inClass:UIViewController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarHidden)
     inClass:UIViewController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}


- (UIInterfaceOrientation)rotation_fix_preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation currentInterface;
    if (@available(iOS 13.0, *)) {
        currentInterface = UIApplication.sharedApplication.windows.firstObject.windowScene.interfaceOrientation;
    } else {
        currentInterface = [UIApplication sharedApplication].statusBarOrientation;
    }
    
    if (self.shouldAutorotate) {
        if (self.supportedInterfaceOrientations & (1 << currentInterface)) {
            return currentInterface;
        } else {
            return self.preferredInterfaceOrientationForPresentation;
        }
    } else {
        return [UIApplication _UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation];
    }
}

- (UIViewController *)rotation_findTopViewController {
    UIViewController *result;
    if ([self isKindOfClass:UINavigationController.class]) {
        result = ((UINavigationController *)self).topViewController.rotation_findTopViewController;
    } else if ([self isKindOfClass:UITabBarController.class]) {
        result = ((UITabBarController *)self).selectedViewController.rotation_findTopViewController;
    } else {
        result = self;
    }
    /**
    修复视频全屏无法横屏
    <UIViewController>
    | <AVPlayerViewController>
    + <AVFullScreenViewController>
    */
    if ([[result presentedViewController] isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]) {
        return [result presentedViewController];
    }
//    if ([[result presentedViewController] isKindOfClass:NSClassFromString(@"UISnapshotModalViewController")]) {
//        return [result presentedViewController];
//    }
    
    result = result ?: self;
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
        [self rotation_hook_shouldAutorotate];
        [self rotation_hook_supportedInterfaceOrientations];
        [self rotation_hook_preferredInterfaceOrientationForPresentation];
        [self rotation_hook_preferredStatusBarStyle];
        [self rotation_hook_prefersStatusBarHidden];
        [self rotation_hook_childViewControllerForStatusBarStyle];
        [self rotation_hook_childViewControllerForStatusBarHidden];
        
        [self rotation_hook_push];
        
        /*
         系统调用这两个方法 没有调用 shouldAutorotate 和 supportedInterfaceOrientations
         导致 界面没有旋转回正确位置
         */
        [self rotation_hook_pop];
        [self rotation_hook_popToController];
        [self rotation_hook_popToRoot];
    });
}

+ (void)rotation_hook_push {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(pushViewController:animated:)
     inClass:UINavigationController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         void (*originalImplementation_)(__unsafe_unretained id, SEL, UIViewController *viewController, BOOL animated);
         SEL selector_ = @selector(pushViewController:animated:);
         return ^void (__unsafe_unretained id self, UIViewController *viewController, BOOL animated) {
             UIViewController *fromViewController = [self viewControllers].lastObject;
             UIViewController *toViewController = viewController;
             [self rotation_setupPrientationWithFromVC:fromViewController toVC:toViewController];
             KZRSSWCallOriginal(viewController, animated);
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

/*
 在系统调用下列两个方法的时候 只有两个相邻的ViewController之间POP才会修复旋转
 所以在这种情况下 在POP超过两个界面的情况下 插入一个中间界面与想要跳转的界面方向相同 即可解决
 */

+ (void)rotation_hook_pop {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(popViewControllerAnimated:)
     inClass:UINavigationController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         UIViewController *(*originalImplementation_)(__unsafe_unretained id, SEL,  BOOL animated);
         SEL selector_ = @selector(popViewControllerAnimated:);
         return ^UIViewController * (__unsafe_unretained id self, BOOL animated) {
             if ([self viewControllers].count < 2) { return nil; }
             UIViewController *fromViewController = [self viewControllers].lastObject;
             UIViewController *toViewController = [self viewControllers][[self viewControllers].count - 2];
             if ([toViewController isKindOfClass:InterfaceOrientationController.class]) { return KZRSSWCallOriginal(animated); }
             if ([fromViewController rotation_fix_preferredInterfaceOrientationForPresentation] == [toViewController rotation_fix_preferredInterfaceOrientationForPresentation]) {
                 return KZRSSWCallOriginal(animated);
             }
             if ([toViewController rotation_fix_preferredInterfaceOrientationForPresentation] == UIInterfaceOrientationPortrait) {
                 return KZRSSWCallOriginal(animated);
             }
             if ([toViewController supportedInterfaceOrientations] & (1 << fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation)) {
                 return KZRSSWCallOriginal(animated);
             }
             __weak __typeof(toViewController) weakToViewController = toViewController;
             toViewController.rotation_viewWillAppearBlock = ^{
                 __strong __typeof(weakToViewController) toViewController = weakToViewController;
                 if (toViewController == nil) { return; }
                 UIInterfaceOrientation ori = toViewController.rotation_fix_preferredInterfaceOrientationForPresentation;
                 [toViewController rotation_forceToOrientation:ori];
                 toViewController.rotation_viewWillAppearBlock = nil;
             };
             return KZRSSWCallOriginal(animated);
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_popToController {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(popToViewController:animated:)
     inClass:UINavigationController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         NSArray<UIViewController *> *(*originalImplementation_)(__unsafe_unretained id, SEL, UIViewController *viewController, BOOL animated);
         SEL selector_ = @selector(popToViewController:animated:);
         return ^NSArray<UIViewController *> * (__unsafe_unretained id self, UIViewController *viewController, BOOL animated) {
             if ([self viewControllers].count < 2) { return nil; }
             UIViewController *fromViewController = [self viewControllers].lastObject;
             UIViewController *toViewController = viewController;
             if ([toViewController isKindOfClass:InterfaceOrientationController.class]) { return KZRSSWCallOriginal(viewController, animated); }
             
             if ([fromViewController rotation_fix_preferredInterfaceOrientationForPresentation] == [toViewController rotation_fix_preferredInterfaceOrientationForPresentation]) {
                 return KZRSSWCallOriginal(viewController, animated);
             }
             if ([toViewController rotation_fix_preferredInterfaceOrientationForPresentation] == UIInterfaceOrientationPortrait) {
                 NSMutableArray<UIViewController *> * vcs = [[self viewControllers] mutableCopy];
                 InterfaceOrientationController *fixController = [[InterfaceOrientationController alloc] initWithRotation:(UIDeviceOrientation)[toViewController rotation_fix_preferredInterfaceOrientationForPresentation]];
                 fixController.view.backgroundColor = [toViewController.view backgroundColor];
                 [vcs insertObject:fixController atIndex:vcs.count - 1];
                 [self setViewControllers:vcs];
                 return [@[[self popViewControllerAnimated:true]] arrayByAddingObjectsFromArray:KZRSSWCallOriginal(viewController, false)];
             }
             if ([toViewController supportedInterfaceOrientations] & (1 << fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation)) {
                 return KZRSSWCallOriginal(viewController, animated);
             }
             __weak __typeof(toViewController) weakToViewController = toViewController;
             toViewController.rotation_viewWillAppearBlock = ^{
                 __strong __typeof(weakToViewController) toViewController = weakToViewController;
                 if (toViewController == nil) { return; }
                 UIInterfaceOrientation ori = toViewController.rotation_fix_preferredInterfaceOrientationForPresentation;
                 [toViewController rotation_forceToOrientation:ori];
                 toViewController.rotation_viewWillAppearBlock = nil;
             };
             return KZRSSWCallOriginal(viewController, animated);
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_popToRoot {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(popToRootViewControllerAnimated:)
     inClass:UINavigationController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         NSArray<UIViewController *> *(*originalImplementation_)(__unsafe_unretained id, SEL, BOOL animated);
         SEL selector_ = @selector(popToRootViewControllerAnimated:);
         return ^NSArray<UIViewController *> * (__unsafe_unretained id self, BOOL animated) {
             if ([self viewControllers].count < 2) { return nil; }
             UIViewController *fromViewController = [self viewControllers].lastObject;
             UIViewController *toViewController = [self viewControllers].firstObject;
             if ([fromViewController rotation_fix_preferredInterfaceOrientationForPresentation] == [toViewController rotation_fix_preferredInterfaceOrientationForPresentation]) {
                 return KZRSSWCallOriginal(animated);
             }
             if ([toViewController rotation_fix_preferredInterfaceOrientationForPresentation] == UIInterfaceOrientationPortrait) {
                 NSMutableArray<UIViewController *> * vcs = [[self viewControllers] mutableCopy];
                 InterfaceOrientationController *fixController = [[InterfaceOrientationController alloc] initWithRotation:(UIDeviceOrientation)UIInterfaceOrientationPortrait];
                 fixController.view.backgroundColor = [toViewController.view backgroundColor];
                 [vcs insertObject:fixController atIndex:vcs.count - 1];
                 [self setViewControllers:vcs];
                 return [@[[self popViewControllerAnimated:true]] arrayByAddingObjectsFromArray:KZRSSWCallOriginal(false)];
             }
             if ([toViewController supportedInterfaceOrientations] & (1 << fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation)) {
                 return KZRSSWCallOriginal(animated);
             }
             __weak __typeof(toViewController) weakToViewController = toViewController;
             toViewController.rotation_viewWillAppearBlock = ^{
                 __strong __typeof(weakToViewController) toViewController = weakToViewController;
                 if (toViewController == nil) { return; }
                 UIInterfaceOrientation ori = toViewController.rotation_fix_preferredInterfaceOrientationForPresentation;
                 [toViewController rotation_forceToOrientation:ori];
                 toViewController.rotation_viewWillAppearBlock = nil;
             };
             return KZRSSWCallOriginal(animated);
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

- (void)rotation_setupPrientationWithFromVC:(UIViewController *)fromViewController toVC:(UIViewController *)toViewController {
    if ([toViewController supportedInterfaceOrientations] & (1 << fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation)) {
        toViewController.rotation_viewWillAppearBlock = nil;
        return;
    }
    if (fromViewController.rotation_fix_preferredInterfaceOrientationForPresentation != toViewController.rotation_fix_preferredInterfaceOrientationForPresentation) {
        __weak __typeof(toViewController) weakToViewController = toViewController;
        __weak __typeof(self) weakSelf = self;
        toViewController.rotation_viewWillAppearBlock = ^{
            __strong __typeof(weakToViewController) toViewController = weakToViewController;
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (toViewController == nil) { return; }
            UIInterfaceOrientation ori = toViewController.rotation_fix_preferredInterfaceOrientationForPresentation;
            [strongSelf rotation_forceToOrientation:ori];
        };
    } else {
        toViewController.rotation_viewWillAppearBlock = nil;
    }
}

+ (void)rotation_hook_shouldAutorotate {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(shouldAutorotate)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController *self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.shouldAutorotate.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultShouldAutorotate] : topVC.shouldAutorotate;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_supportedInterfaceOrientations {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(supportedInterfaceOrientations)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientationMask (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.supportedInterfaceOrientations.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

/// 此方法只针对 present 出来的controller 管用, 在push 的时候不起作用
/// 所以在下边UINavigationController 处 做了处理
+ (void)rotation_hook_preferredInterfaceOrientationForPresentation {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredInterfaceOrientationForPresentation)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientation (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredInterfaceOrientationForPresentation.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_preferredStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredStatusBarStyle)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIStatusBarStyle (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredStatusBarStyle.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_prefersStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(prefersStatusBarHidden)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.prefersStatusBarHidden.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarStyle)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarHidden)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

@end

@implementation UITabBarController (Rotate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self rotation_hook_shouldAutorotate];
        [self rotation_hook_supportedInterfaceOrientations];
        [self rotation_hook_preferredInterfaceOrientationForPresentation];
        [self rotation_hook_preferredStatusBarStyle];
        [self rotation_hook_prefersStatusBarHidden];
        [self rotation_hook_childViewControllerForStatusBarStyle];
        [self rotation_hook_childViewControllerForStatusBarHidden];
        
        [self rotation_hook_setSelectedIndex];
        [self rotation_hook_setSelectedViewController];
    });
}

+ (void)rotation_hook_setSelectedIndex {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(setSelectedIndex:)
     inClass:UITabBarController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         void(*originalImplementation_)(__unsafe_unretained id, SEL, NSUInteger selectedIndex);
         SEL selector_ = @selector(setSelectedIndex:);
         return ^void (__unsafe_unretained id self, NSUInteger selectedIndex) {
             UIViewController *fromVC = [self selectedViewController];
             KZRSSWCallOriginal(selectedIndex);
             UIViewController *toVc = [self selectedViewController];
             if ([toVc supportedInterfaceOrientations] & (1 << fromVC.rotation_fix_preferredInterfaceOrientationForPresentation)) {
                 return;
             }
             UIInterfaceOrientation ori = toVc.rotation_fix_preferredInterfaceOrientationForPresentation;
             [self rotation_forceToOrientation:ori];
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_setSelectedViewController {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(setSelectedViewController:)
     inClass:UITabBarController.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         void(*originalImplementation_)(__unsafe_unretained id, SEL, __kindof UIViewController *selectedViewController);
         SEL selector_ = @selector(setSelectedViewController:);
         return ^void (__unsafe_unretained id self, __kindof UIViewController *selectedViewController) {
             UIViewController *fromVC = [self selectedViewController];
             KZRSSWCallOriginal(selectedViewController);
             UIViewController *toVc = [self selectedViewController];
             if ([toVc supportedInterfaceOrientations] & (1 << fromVC.rotation_fix_preferredInterfaceOrientationForPresentation)) {
                 return;
             }
             UIInterfaceOrientation ori = toVc.rotation_fix_preferredInterfaceOrientationForPresentation;
             [self rotation_forceToOrientation:ori];
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_shouldAutorotate {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(shouldAutorotate)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController *self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.shouldAutorotate.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultShouldAutorotate] : topVC.shouldAutorotate;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_supportedInterfaceOrientations {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(supportedInterfaceOrientations)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientationMask (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.supportedInterfaceOrientations.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultSupportedInterfaceOrientations] : topVC.supportedInterfaceOrientations;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

/// 此方法只针对 present 出来的controller 管用, 在push 的时候不起作用
/// 所以在下边UINavigationController 处 做了处理
+ (void)rotation_hook_preferredInterfaceOrientationForPresentation {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredInterfaceOrientationForPresentation)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIInterfaceOrientation (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredInterfaceOrientationForPresentation.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation] : topVC.preferredInterfaceOrientationForPresentation;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_preferredStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(preferredStatusBarStyle)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIStatusBarStyle (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.preferredStatusBarStyle.integerValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPreferredStatusBarStyle] : topVC.preferredStatusBarStyle;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_prefersStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(prefersStatusBarHidden)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^BOOL (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             UIViewControllerRotationModel *preference = [self rotation_getPreferenceInternalClassModel:topVC.class];
             if (preference) return preference.prefersStatusBarHidden.boolValue;
             return topVC == self ? [UIApplication _UIApplicationRotationDefaultPrefersStatusBarHidden] : topVC.prefersStatusBarHidden;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarStyle {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarStyle)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}

+ (void)rotation_hook_childViewControllerForStatusBarHidden {
    [KZRSSwizzle
     swizzleInstanceMethod:@selector(childViewControllerForStatusBarHidden)
     inClass:self.class
     newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
         return ^UIViewController* (__unsafe_unretained UIViewController * self) {
             UIViewController *topVC = self.rotation_findTopViewController;
             return topVC == self ? nil : topVC;
         };
     }
     mode:KZRSSwizzleModeAlways
     key:NULL];
}
@end

@implementation UIApplication (Rotate)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [KZRSSwizzle
         swizzleInstanceMethod:@selector(setDelegate:)
         inClass:UIApplication.class
         newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
             void(*originalImplementation_)(__unsafe_unretained id, SEL, id<UIApplicationDelegate> delegate);
             SEL selector_ = @selector(setDelegate:);
             return ^void (__unsafe_unretained id self, id<UIApplicationDelegate> delegate) {
                 [self hook_setDelegate:delegate];
                 KZRSSWCallOriginal(delegate);
             };
         }
         mode:KZRSSwizzleModeAlways
         key:NULL];
    });
}

- (void)hook_setDelegate:(id<UIApplicationDelegate>)delegate {
    SEL selector = @selector(application:supportedInterfaceOrientationsForWindow:);
    struct objc_method_description protocol_del = protocol_getMethodDescription(@protocol(UIApplicationDelegate), selector, false, true);
    Method method = class_getInstanceMethod([delegate class], protocol_del.name);
    id block = ^UIInterfaceOrientationMask(__unsafe_unretained id self, UIApplication *application, UIWindow *window) {
        return UIInterfaceOrientationMaskAll;
    };
    if (method) {
        [KZRSSwizzle
         swizzleInstanceMethod:protocol_del.name
         inClass:[delegate class]
         newImpFactory:^id(KZRSSwizzleInfo *swizzleInfo) {
             return block;
         }
         mode:KZRSSwizzleModeAlways
         key:NULL];
    } else {
        IMP newIMP = imp_implementationWithBlock(block);
        class_addMethod([delegate class], protocol_del.name, newIMP, protocol_del.types);
    }
}

+ (BOOL)_UIApplicationRotationDefaultShouldAutorotate {
    return [UIViewControllerRotateDefault shared].defaultShouldAutorotate;
}

+ (UIInterfaceOrientationMask)_UIApplicationRotationDefaultSupportedInterfaceOrientations {
    return [UIViewControllerRotateDefault shared].defaultSupportedInterfaceOrientations;
}

+ (UIInterfaceOrientation)_UIApplicationRotationDefaultPreferredInterfaceOrientationForPresentation {
    return [UIViewControllerRotateDefault shared].defaultPreferredInterfaceOrientationForPresentation;
}

+ (UIStatusBarStyle)_UIApplicationRotationDefaultPreferredStatusBarStyle {
    return [UIViewControllerRotateDefault shared].defaultPreferredStatusBarStyle;
}

+ (BOOL)_UIApplicationRotationDefaultPrefersStatusBarHidden {
    return [UIViewControllerRotateDefault shared].defaultPrefersStatusBarHidden;
}
@end
