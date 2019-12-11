

Pod::Spec.new do |spec|

  spec.name         = "KKSandboxUI"

  spec.version      = '1.0.0'

  spec.summary      = "viewer sand box file"

  spec.description  = <<-DESC
iewer sand box file, create, share, delete
DESC

  spec.swift_version = '5.0'

  spec.homepage     = "https://github.com/onetys"

  spec.license      = "MIT"

  spec.author       = { "wangtieshan" => "onetys@163.com" }

  spec.platform     = :ios, "8.0"

  spec.source = { :git => 'https://github.com/onetys/KKSandboxUI.git', :tag => spec.version }

  spec.pod_target_xcconfig = { 'BITCODE_GENERATION_MODE' => 'bitcode', 'ENABLE_BITCODE' => 'YES' }

  spec.source_files = "KKSandboxUI/KKSandboxUI/**/*.{h,m,swift}"

  spec.resource  = "KKSandboxUI/KKSandboxUI/**/*.lproj", "KKSandboxUI/KKSandboxUI/KKSandboxUI.bundle"

end
