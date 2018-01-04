#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name                      = "LeomaFramework"
  s.version                   = "1.0"
  s.summary                   = "Leoma Hybrid Bridge"
  s.description               = <<-DESC
                                An optional longer description of LeomaFramework

                                * Markdown format.
                                * Don't worry about the indent, we strip it!
                              DESC
  s.homepage                  = "https://github.com/humphrywang"
  s.license                   =  { :type => "Apache", :file => "LICENSE" }
  s.author                    = { "humphrywang" => "humphrywang@hotmail.com" }
  s.source                    = { :git => "https://github.com/humphrywang/LeomaFramework.git", :tag => s.version }

  s.platform                  = :ios, '6.0'

  s.subspec 'Base64' do |base64|
    base64.source_files = 'LeomaVendor/Base64/*.{h,m}'
    base64.requires_arc = false
  end

  s.subspec 'JSONKit' do |json|
    json.source_files = 'LeomaVendor/JSONKit/*.{h,m}'
    json.requires_arc = false
  end

  s.subspec 'IdentifierAddition' do |ia|
    ia.source_files = 'LeomaVendor/IdentifierAddition/*.{h,m}'
    ia.requires_arc = false
  end

  s.subspec 'InteractiveLeoma' do |core|
    core.source_files               = '**/*.{h,m}'
    core.private_header_files       = 'LeomaCore/WebView/LeomaUIWebView.h', 'LeomaCore/WebView/LeomaWKWebView.h', 'LeomaNavigator/LeomaNavigationBarS.h', 'LeomaNavigator/LeomaEffectiveNavigation.h', 'LeomaNavigator/LeomaMaskView.h'
    core.exclude_files              = 'LeomaVendor'
    core.resource                   = ['**/*png', '**/*.xib', '**/*.script']
    core.framework                  = 'WebKit'
    core.dependency                'ASIHTTPRequest'
    core.dependency                'Reachability'
    core.dependency                'LeomaFramework/Base64'
    core.dependency                'LeomaFramework/JSONKit'
    core.dependency                'LeomaFramework/IdentifierAddition'
    core.prefix_header_contents    = '#import "LeomaSystem.h"', '#import "LeomaCategories.h"', '#import "LeomaLog.h"', '#import "LeomaUtils.h"', '#import "LeomaDefine.h"'
  end

end
