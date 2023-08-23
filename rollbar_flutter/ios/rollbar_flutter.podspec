#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rollbar_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rollbar_flutter'
  s.version          = '1.4.2'
  s.summary          = 'Connect your Flutter applications to Rollbar for error reporting.'
  s.description      = <<-DESC
Connect your Flutter applications to Rollbar for error reporting.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rollbar' => 'support@rollbar.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'RollbarNotifier', '~> 3.2.0'
  s.static_framework = true
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES',
                            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
