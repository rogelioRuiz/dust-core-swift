# Xcode 26 beta workaround: duplicate .modulemap files in the SDK cause
# "redefinition of module" errors with explicit modules enabled.
xcode_major = begin
  m = `xcrun xcodebuild -version 2>/dev/null`.to_s.match(/Xcode (\d+)/)
  m ? m[1].to_i : 0
rescue
  0
end

Pod::Spec.new do |s|
  s.name = 'DustCore'
  s.version = File.read(File.join(__dir__, 'VERSION')).strip
  s.summary = 'DustCore contract types and protocols for on-device ML.'
  s.license = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.homepage = 'https://github.com/rogelioRuiz/dust-core-swift'
  s.author = 'Techxagon'
  s.source = { :git => 'https://github.com/rogelioRuiz/dust-core-swift.git', :tag => s.version.to_s }

  s.source_files = 'Sources/DustCore/**/*.swift'
  s.module_name = 'DustCore'
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.9'

  if xcode_major >= 26
    s.pod_target_xcconfig = { 'SWIFT_ENABLE_EXPLICIT_MODULES' => 'NO' }
  end
end
