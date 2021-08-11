require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-alibc"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/kafudev/react-native-alibc.git", :tag => "#{s.version}" }
  # source 'http://repo.baichuan-ios.taobao.com/baichuanSDK/AliBCSpecs.git'

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"
  s.dependency 'AlibcTradeSDK','4.0.1.15'
  s.dependency 'AliAuthSDK','1.1.0.42-BC3'
  s.dependency 'mtopSDK','3.0.0.3-BC'
  s.dependency 'securityGuard','5.4.191'
  s.dependency 'AliLinkPartnerSDK','4.0.0.24'
  s.dependency 'BCUserTrack','5.2.0.18-appkeys'
  s.dependency 'UTDID','1.5.0.91'
  s.dependency 'WindVane','8.5.0.46-bc11'

  s.frameworks = "CoreMotion", "CoreTelephony"

  s.compiler_flags = '-lstdc++', '-ObjC'
end
