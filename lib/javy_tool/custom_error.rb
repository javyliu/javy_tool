module JavyTool
  module CustomError
    class Error < StandardError; end

    class AccessDenied < Error
      attr_reader :action, :subject
      attr_writer :default_message

      def initialize(message = nil, action = nil, subject = nil)
        @message = message
        @action = action
        @subject = subject
        @default_message = I18n.t(:"custom_error.default", :default => "Access this page error.")
      end

      def to_s
        @message || @default_message
      end
    end
  end
end

