Pod::Spec.new do |s|
  s.name          = "PHImageKit"
  s.version       = "0.1.3.1"
  s.summary       = "Simple yet powerful image downloading, caching and GIF playback framework."
  s.homepage      = "https://github.com/producthunt/PHImageKit"
  s.license       = { type: 'MIT', file: 'LICENSE' }
  s.author        = { "Product Hunt" => "hello@producthunt.com" }
  s.platform      = :ios, '8.0'
  s.source        = { git: "https://github.com/producthunt/PHImageKit.git", tag: s.version }
  s.source_files  = "PHImageKit/**/*.{swift}"
  s.description   = <<-TEXT
  - Download image or GIF and display it with just a single call
  - Caches both in memory and in file storage
  - Plays multiple GIFs simultaneously
  - Eliminates delays or blocking during the first playback loop of GIFs
  - Written in Swift
  
  PHImageKit is the component that powers all images and GIFs in ProductHunt iOS App
TEXT
end
