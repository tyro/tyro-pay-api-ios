#
# Be sure to run `pod lib lint mypod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'tyro-pay-api-ios'
  s.version          = '1.0.0'
  s.summary          = 'The Pay API SDK for iOS'
  s.swift_version    = '5.9'

  s.description      = <<-DESC
  The Pay API SDK for iOS
                       DESC

  s.homepage         = 'https://github.com/tyro/tyro-pay-api-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/tyro/tyro-pay-api-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'mypod/Classes/**/*'
end
