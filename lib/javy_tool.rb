require "javy_tool/version"

module JavyTool
  autoload :Utils, "javy_tool/utils"
  autoload :Breadcrumb, "javy_tool/breadcrumb"
  mattr_accessor :tool_config
  mattr_accessor :upload_path
  @@upload_path = "/tmp"

  def self.setup
    yield self
  end
  def self.options
    @@options ||= {
      :upload_path => upload_path
    }
  end
end
