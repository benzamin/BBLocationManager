Pod::Spec.new do |s|
  s.name     = 'BBLocationManager'
  s.version  = '1.1'
  s.license  = 'MIT'
  s.description  = <<-DESC
            A Location Manager for easily implementing location services & geofencing in iOS, written in Objective-C. iOS 11 Ready.
                   DESC

  s.summary  = 'A Location Manager for easily implementing location services & geofencing in iOS'
  s.homepage = 'https://github.com/benzamin/BBLocationManager'
  s.screenshots  = "https://raw.githubusercontent.com/benzamin/BBLocationManager/master/screens/locationNgeofence.gif"
  s.social_media_url = 'http://twitter.com/benzamin1985'
  s.authors  = { 'Benzamin Basher' => 'benzamin1985@gmail.com' }
  s.source   = { :git => 'https://github.com/benzamin/BBLocationManager.git', :tag => s.version }
  s.requires_arc = true
  
  s.public_header_files = 'BBLocationManager/BBLocationManagerClasses/BBLocationManager.h'
  s.source_files  = "BBLocationManager/BBLocationManagerClasses/BBLocationManager.{h,m}"
  s.platform     = :ios, "7.0"
  s.frameworks = 'CoreLocation'
  end