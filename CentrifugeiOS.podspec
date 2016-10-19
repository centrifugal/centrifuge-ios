Pod::Spec.new do |s|
  s.name             = "CentrifugeiOS"
  s.version          = "0.1.0"
  s.summary          = "Swifty iOS client for Centrifuge."
  s.description      = <<-DESC
  iOS client for Centrifuge https://github.com/centrifugal/Centrifuge. It uses SwiftWebSocket and helpers classes to communicate with Centrifuge server.
                       DESC

  s.homepage         = "https://github.com/centrifugal/centrifuge-ios"
  s.license          = 'MIT'
  s.author           = { "Herman Saprykin" => "saprykin.h@gmail.com" }
  s.source           = { :git => "https://github.com/centrifugal/centrifuge-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/saprykinh'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CentrifugeiOS/Classes/**/*'

  s.dependency 'SwiftWebSocket', '2.6.4'
  s.dependency 'IDZSwiftCommonCrypto', '0.8.1'
end
