Pod::Spec.new do |s|
  s.name         = 'Evervault'
  s.version      = '2.1.0'
  s.summary      = 'Evervault iOS SDK for encryption, payment inputs, and enclave attestation'
  s.homepage     = 'https://github.com/evervault/evervault-ios'
  s.license      = { :type => 'Apache-2.0', :file => 'LICENCE' }
  s.author       = { 'Evervault' => 'support@evervault.com' }
  s.source       = { :git => 'https://github.com/evervault/evervault-ios.git', :tag => s.version.to_s }
  s.platform     = :ios, '15.0'
  s.swift_version = '5.7'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/EvervaultCore/**/*.swift'
  end

  s.subspec 'Inputs' do |inputs|
    inputs.source_files = 'Sources/EvervaultInputs/**/*.swift'
    inputs.dependency 'Evervault/Core'
    inputs.dependency 'EvervaultPayment', '>= 0.0.21'
    inputs.resource_bundles = {
      'EvervaultInputs' => [
        'Sources/EvervaultInputs/Resources/**/*.xcassets',
        'Sources/EvervaultInputs/Resources/**/*.lproj'
      ]
    }
  end

  s.subspec 'Enclaves' do |enclaves|
    enclaves.source_files = 'Sources/EvervaultEnclaves/**/*.swift'
    enclaves.dependency 'Evervault/Core'
    enclaves.vendored_frameworks = 'AttestationBindings.xcframework'
    enclaves.prepare_command = 'unzip -o AttestationBindings.xcframework.zip'
  end
end
