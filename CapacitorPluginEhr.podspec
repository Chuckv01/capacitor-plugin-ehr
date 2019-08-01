
  Pod::Spec.new do |s|
    s.name = 'CapacitorPluginEhr'
    s.version = '0.0.1'
    s.summary = 'Ionic Capacitor plugin to access iOS Clinical Records (FHIR)'
    s.license = 'MIT'
    s.homepage = 'https://github.com/Chuckv01/capacitor-plugin-ehr'
    s.author = 'Charles Vanderhoff'
    s.source = { :git => 'https://github.com/Chuckv01/capacitor-plugin-ehr', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end