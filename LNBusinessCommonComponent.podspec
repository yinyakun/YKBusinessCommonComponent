#
# Be sure to run `pod lib lint LNBusinessCommonComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LNBusinessCommonComponent'
  s.version          = '0.1.10'
  s.summary          = '发送邮件包含 附件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
2.添加录音功能,添加失败回调
                       DESC

  s.homepage         = 'https://github.com/yinyakun/LNBusinessCommonComponent'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yinyakun' => 'yinyakun123@126.com' }
  s.source           = { :git => 'http://gitlab.xpaas.lenovo.com/yinyk1/LNBusinessCommonComponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LNBusinessCommonComponent/Classes/*'



    s.subspec 'WaterImage' do |c|
    c.source_files = 'LNBusinessCommonComponent/Classes/WaterImage/**/*'
    end

    s.subspec 'SendEmail' do |e|
    e.source_files = 'LNBusinessCommonComponent/Classes/SendEmail/**/*'
    end

    s.subspec 'VoiceRecorder' do |v|
    v.source_files = 'LNBusinessCommonComponent/Classes/VoiceRecorder/**/*'
    end

    # s.subspec 'LNUMShare' do |share|
    #    share.source_files = 'LNBusinessCommonComponent/Classes/LNUMShare/**/*'
    #   share.dependency 'UMCCommon'
    #   share.dependency 'UMCSecurityPlugins'
    #   share.dependency 'UMCShare/UI'
    #   share.dependency 'UMCShare/Social/WeChat'
        # 集成QQ/QZone/TIM(完整版7.6M)
        #   share.dependency 'UMCShare/Social/QQ'
        #   share.dependency 'UMCShare/Social/Sina'
        #   share.dependency 'UMCShare/Social/Email'
        #end
  
  # s.resource_bundles = {
  #   'LNBusinessCommonComponent' => ['LNBusinessCommonComponent/Assets/*.png']
  # }

    s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'AVFoundation'
    s.dependency 'AFNetworking','~> 3.0'

end
