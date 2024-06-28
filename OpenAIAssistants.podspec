Pod::Spec.new do |s|
  s.name             = 'OpenAIAssistants'
  s.version          = '0.1.1'
  s.summary          = 'OpenAI Assistants API client.'
  s.description      = 'Swift library for the OpenAI Assistants API'
  s.homepage         = 'https://github.com/exyte/openai-assistants-api'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/openai-assistants-api.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = '16.0'
  s.osx.deployment_target = '13.0'
  s.tvos.deployment_target = '16.0'
  s.watchos.deployment_target = '8.0'

  s.swift_version = "5.7"
  s.source_files = 'OpenAIAssistants/Source/**/*'

  s.dependency 'EventSourceHttpBody', '~> 0.1.0'
end
