#
# Be sure to run `pod lib lint Ajimi.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Ajimi"
  s.version          = "0.10.0"
  s.summary          = "Ajimi means tasting. In Japanese, 味見. Ajimi is the feedback tool, which anyone can easily feedback a report any time.
"
  s.homepage         = "https://github.com/nakajijapan/Ajimi"
  s.license          = 'MIT'
  s.author           = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source           = { :git => "https://github.com/nakajijapan/Ajimi.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nakajijapan'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Source/Classes/**/*'
  s.resource_bundles = {
    'Ajimi' => ['Source/Assets/*.png']
  }

end
