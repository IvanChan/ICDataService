#
# Be sure to run `pod lib lint ICDataService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ICDataService'
  s.version          = '0.9.0'
  s.summary          = 'Service that requesting data from different path of same host.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Wrapped Service that requesting data from different path of same host, base on NSURLSession.
                       DESC

  s.homepage         = 'https://github.com/IvanChan/ICDataService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '_ivanC' => '_ivanC' }
  s.source           = { :git => 'https://github.com/IvanChan/ICDataService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.public_header_files = 'ICDataService/Classes/ICDataService.h'
  s.source_files = 'ICDataService/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ICDataService' => ['ICDataService/Assets/*.png']
  # }

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
