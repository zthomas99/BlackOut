
# Uncomment the next line to define a global platform for your project
# platform :ios, '15.6'

target 'BlackOut' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlackOut
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'FLAnimatedImage'
  # GooglePlaces migrated to Swift Package Manager (CocoaPods deprecated Aug 2025)
  pod 'DKImagePickerController'
  pod 'Layoutless'

  target 'BlackOutTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BlackOutUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
    end

    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        next unless file.settings && file.settings['COMPILER_FLAGS']
        flags = file.settings['COMPILER_FLAGS'].split
        flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
        file.settings['COMPILER_FLAGS'] = flags.join(' ')
      end
    end
  end

  grpc_files = [
    'Pods/gRPC-C++/src/core/lib/promise/detail/basic_seq.h',
    'Pods/gRPC-Core/src/core/lib/promise/detail/basic_seq.h'
  ]

  grpc_files.each do |path|
    next unless File.exist?(path)

    text = File.read(path)
    old_text = 'Traits::template CallSeqFactory(f_, *cur_, std::move(arg))'
    new_text = 'Traits::template CallSeqFactory<>(f_, *cur_, std::move(arg))'

    if text.include?(old_text)
      File.open(path, 'w') { |f| f.write(text.gsub(old_text, new_text)) }
      puts "Patched #{path}"
    end
  end

  # GooglePlaces includes both a legacy .framework and an .xcframework package.
  # On simulator builds, the legacy device-only framework can be selected first.
  # Remove that search path from generated aggregate xcconfigs so CocoaPods links the xcframework slice.
  aggregate_xcconfigs = [
    'Pods/Target Support Files/Pods-BlackOut/Pods-BlackOut.debug.xcconfig',
    'Pods/Target Support Files/Pods-BlackOut/Pods-BlackOut.release.xcconfig'
  ]

  aggregate_xcconfigs.each do |path|
    next unless File.exist?(path)
    text = File.read(path)
    old_path = '"${PODS_ROOT}/GooglePlaces/Frameworks"'
    next unless text.include?(old_path)
    File.open(path, 'w') { |f| f.write(text.gsub(old_path, '')) }
    puts "Patched #{path} to prefer GooglePlaces.xcframework"
  end

  # Inject Secrets.xcconfig so gitignored API keys are available as build settings.
  # Secrets.xcconfig lives at the project root; the xcconfigs are 3 directories deep.
  secrets_include = '#include? "../../../Secrets.xcconfig"'
  aggregate_xcconfigs.each do |path|
    next unless File.exist?(path)
    text = File.read(path)
    next if text.include?(secrets_include)
    File.open(path, 'w') { |f| f.write(secrets_include + "\n" + text) }
    puts "Injected Secrets.xcconfig include into #{path}"
  end
end
