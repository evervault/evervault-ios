Pod::Spec.new do |s|
  s.name         = "Evervault"
  s.version      = "0.3.1"
  s.summary      = "Evervault iOS SDK"
  s.description  = <<-DESC
                    Evervault SDK for iOS.
                   DESC
  s.homepage     = "https://github.com/evervault/evervault-ios"
  s.license      = { :type => "MIT" }
  s.author       = { "Eoin Boylan" => "engineering@evervault.com", "Donal Tuhoy" => "donal@evervault.com" }
  s.source       = { :git => "https://github.com/evervault/evervault-ios.git" }
  s.platform     = :ios, '13.0'
  s.swift_version = '5.0'

  s.subspec 'EvervaultCore' do |core|
    core.source_files = 'Sources/EvervaultCore/**/*.{h,m,swift}'
  end
end
