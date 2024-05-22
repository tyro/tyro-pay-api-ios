#
# Be sure to run `pod lib lint mypod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TyroApplePay'
  s.version          = '0.0.2'
  s.summary          = 'The Pay API SDK for iOS'
  s.swift_version    = '5.9'

  s.description      = <<-DESC
  The Pay API SDK for iOS is intended to help partners to integrate seamlessly to the Pay API.
                       DESC

  s.homepage         = 'https://github.com/tyro/tyro-pay-api-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'team-9and3quarters' => 'team-9and3quarters@tyro.com' }
  s.source           = { :git => 'https://github.com/tyro/tyro-pay-api-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.platform = :ios, '14.0'
  s.source_files = 'Sources/**/*'

  s.dependency 'Factory'
  s.dependency 'SwiftyBeaver'
end
