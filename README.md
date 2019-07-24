# UIViewControllerRotation
屏幕旋转控制类, 耦合性低, 但因为用到了runtime 所以有侵入性,

## 使用情景:
现在市面上大部分app 并不是所有页面都可以旋转屏幕, 一般只有些许几个页面需要旋转屏幕, 比如查看文档, 观看视频等界面.
这个扩展应运而生, 专门管理这个旋转状态, 默认界面都禁止旋转, 需要旋转的界面重写系统方法即可.

## 为什么用OC:
如果按照一般的写法需要以下步骤
1. 就应该是创建`BaseViewController`, `BaseNavigationController`, `BaseTabBarController` 这三个基类,
2. 修改其 `shouldAutorotate`, `supportedInterfaceOrientations`, `preferredInterfaceOrientationForPresentation` 方法来实现个别界面旋转效果

但是这样项目的耦合性就非常大, 需要所有类都进行继承, 所以想到用扩展的方法实现, 但是swift的extension 不支持重写父类方法, 所以这里用OC实现

## 添加方法:
1. 往项目中拖入文件
2. 用cocoapods引入, 在Podfile中添加
```ruby
pod 'UIViewControllerRotation'
```

## 使用方法
在需要旋转的界面重写下面方法即可 非常低耦合:
- `shouldAutorotate`  <font color=#f00>默认返回</font> `true`
- `supportedInterfaceOrientations` <font color=#f00>默认返回</font> `UIInterfaceOrientationMaskPortrait`
- `preferredInterfaceOrientationForPresentation` <font color=#f00>默认返回</font> `UIInterfaceOrientationPortrait`
- `preferredStatusBarStyle` <font color=#f00>默认返回</font> `UIStatusBarStyleDefault`
- `prefersStatusBarHidden` <font color=#f00>默认返回</font> `false`

PS.如遇到某些类想要强制修改其方向, 需要用到 `UIViewControllerRotationModel` 进行设置

目前已经包含的内部类包括:
1. AVFullScreenViewController
2. AVPlayerViewController
3. AVFullScreenViewController
4. AVFullScreenPlaybackControlsViewController
5. WebFullScreenVideoRootViewController
6. UISnapshotModalViewController
7. UIAlertController // 10.0以下递归崩溃

## 风险提示:
本扩展使用runtime替换了以下方法, 如果有冲突请自行修改或寻找其他解决方案:
- UIViewController:
  - @selector(presentViewController:animated:completion:)
  - @selector(dismissViewControllerAnimated:completion:)
  - @selector(viewWillAppear:)
- UINavigationController:
  - @selector(pushViewController:animated:)
  - @selector(popToViewController:animated:)
  - @selector(popToRootViewControllerAnimated:)
- UITabBarController:
  - @selector(setSelectedIndex:)
  - @selector(setSelectedViewController:)
- UIApplication:
  - @selector(setDelegate:)
- UIApplication.delegate
- @selector(application:supportedInterfaceOrientationsForWindow:)  强制返回ALL, 否则会导致 presented 的 界面 dismiss 时 crash


## Author

赵国庆, kagen@kagenz.com

## License

UIViewControllerRotation is available under the MIT license. See the LICENSE file for more info.
