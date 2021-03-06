module JavyTool
  module Csv
    module ClassMethods
      require 'csv'
      #used to export xls or csv file
      #need to extend in model
      #use like following:
      #  format.xls {send_data @checkinouts.to_csv(col_sep: "\t")}
      # or
      #  select_columns = "id,name,user_id"
      #  format.xls {send_data @checkinouts.select(_select_columns).to_csv(select: _select_columns)}
      def to_csv(options = {},&block)
        select_values = options.delete(:select)
        objs = options.delete(:objs) # model instances list
        select_values = select_values.split(",").collect{|e| e.split(/\s+|\./).last} if select_values.kind_of?(String)
        options[:col_sep] ||= "\t"
        CSV.generate(options) do |csv|
          cols = select_values.presence || column_names
          csv << cols
          (objs || all).each do |item|
            if block_given?
              csv << yield(item,cols)
            else
              csv << item.attributes.values_at(*cols)
            end
          end
        end
      end
    end


    def self.included(receiver)
      receiver.extend   ClassMethods
    end
  end
end
