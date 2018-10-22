Pod::Spec.new do |s|
  s.name             = 'UIViewControllerRotation'
  s.version          = '0.1.0'
  s.summary          = '非耦合性的使界面支持旋转'
  
  s.description      = <<-DESC
非耦合性的使界面支持旋转, 只需要在想要旋转的界面中重写相应方法即可支持旋转
                       DESC

  s.homepage         = 'https://github.com/kagenZhao/UIViewControllerRotation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kagenZhao' => 'kagen@kagenz.com' }
  s.source           = { :git => 'https://github.com/kagenZhao/UIViewControllerRotation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'UIViewControllerRotation/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'
end
