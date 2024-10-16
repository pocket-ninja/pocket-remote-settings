Pod::Spec.new do |s|
  s.name             = 'PocketRemoteSettings'
  s.version          = '0.0.11'
  s.summary          = 'The Pocket Ninja Remote Settings client.'

  s.homepage         = 'https://github.com/pocket-ninja/pocket-remote-settings'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'egor mihneivch' => 'cursed.elfenlaid@gmail.com' }
  s.source           = { :git => 'git@github.com:pocket-ninja/pocket-remote-settings.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.5'
  s.static_framework = true

  s.source_files = 'PocketRemoteSettings/Sources/**/*'
  s.dependency 'Firebase/RemoteConfig'
end
