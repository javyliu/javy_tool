module JavyTool
  module Csv
    module ClassMethods
      #used to export xls or csv file
      #need to extend in model
      def to_csv(options = {})
        select_values = options.delete(:select)
        select_values = select_values.split(",") if select_values.kind_of?(String)
        options[:col_sep] ||= "\t"
        CSV.generate(options) do |csv|
          cols = select_values.presence || column_names
          csv << cols
          all.each do |item|
            csv << item.attributes.values_at(*cols)
          end
        end
      end

    end


    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
