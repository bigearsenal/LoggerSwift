Pod::Spec.new do |s|
  s.name             = 'LoggerSwift'
  s.version          = '1.0.0'
  s.summary          = 'Powerful Logger for swift.'
  
  s.description      = <<-DESC
A powerful logger for swift with flexible filters
                       DESC

  s.homepage         = 'https://github.com/bigearsenal/loggerswift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chung Tran' => 'bigearsenal@gmail.com' }
  s.source           = { :git => 'https://github.com/bigearsenal/loggerswift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/LoggerSwift/**/*'
  s.swift_version = '5.0'

  s.pod_target_xcconfig = {
    'SWIFT_OPTIMIZATION_LEVEL' => '-O'
  }
end
