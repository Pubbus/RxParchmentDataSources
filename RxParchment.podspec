Pod::Spec.new do |spec|
  spec.name         = "RxParchment"
  spec.version      = "1.0.0"
  spec.summary      = "A reactive wrapper built around Parchment"
  spec.homepage     = "https://github.com/Pubbus/RxParchmentDataSources"
  spec.license      =  { :type => "MIT" }
  spec.author             = { "Pubbus" => "lephihungch@gmail.com" }
  spec.platform     = :ios, "8.2"
  spec.source       = { :git => "https://github.com/Pubbus/RxParchmentDataSources.git", :tag => "#{spec.version}" }
  spec.source_files  = "RxParchment/Sources/**/*.swift"
  spec.dependency "RxSwift", "6.1.0"
  spec.dependency "RxCocoa", "6.1.0"
  spec.dependency "Parchment", "1.7.0"

end
