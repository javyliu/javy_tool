require "javy_tool/version"

module JavyTool
  autoload :Utils, "javy_tool/utils"
  autoload :Breadcrumb, "javy_tool/breadcrumb"
  autoload :Csv, "javy_tool/csv"
  autoload :ConstructQuery, "javy_tool/construct_query"
  autoload :CustomError, "javy_tool/custom_error"
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
