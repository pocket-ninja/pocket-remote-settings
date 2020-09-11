Pod::Spec.new do |s|
  s.name             = 'PocketRemoteSettings'
  s.version          = '0.0.2'
  s.summary          = 'The Pocket Ninja Remote Settings client.'

  s.homepage         = 'https://github.com/pocket-ninja/pocket-remote-settings'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egor mihneivch' => 'cursed.elfenlaid@gmail.com' }
  s.source           = { :git => 'git@github.com:pocket-ninja/pocket-remote-settings.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.3'
  s.static_framework = true

  s.source_files = 'PocketRemoteSettings/Sources/**/*'

  s.dependency 'RxSwift', '~> 5'
  s.dependency 'RxRelay'
  s.dependency 'RxCocoa'
  s.dependency 'Firebase/RemoteConfig'
end
