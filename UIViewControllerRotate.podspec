Pod::Spec.new do |s|
  s.name             = 'UIViewControllerRotate'
  s.version          = '1.0.4'
  s.summary          = '非耦合性的使界面支持旋转'

  s.description      = <<-DESC
  屏幕旋转控制类, 耦合性低, 但因为用到了runtime 所以有侵入性,
  现在市面上大部分app 并不是所有页面都可以旋转屏幕, 一般只有些许几个页面需要旋转屏幕, 比如查看文档, 观看视频等界面.
  这个扩展应运而生, 专门管理这个旋转状态, 默认界面都禁止旋转, 需要旋转的界面重写系统方法即可.
                         DESC

  s.homepage         = 'https://github.com/kagenZhao/UIViewControllerRotate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kagenZhao' => 'kagen@kagenz.com' }
  s.source           = { :git => 'https://github.com/kagenZhao/UIViewControllerRotate.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'UIViewControllerRotate/Classes/**/*'
  s.public_header_files = 'UIViewControllerRotate/Classes/**/*.h'
end
