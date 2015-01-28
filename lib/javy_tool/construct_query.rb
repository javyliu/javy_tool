module JavyTool
  module ConstructQuery
    module InstanceMethods
      #like_ary：需要作like查询的字段，数组类型
      #model_class: 查询的类名，字符串类型
      #param: 查询参数,为空的话默认用model_class参数的underscore版本
      #返回数组 [普通条件，like条件]
      def construct_condition(model_class,like_ary: [],param: nil)
        model_class = model_class.to_s
        _class = model_class.classify.constantize
        param =  param || model_class.underscore
        #instance variable need to be remove
        _obj = _class.send(:new,params[param])
        self.instance_variable_set("@#{param}", _obj)

        if params[param]
          con_hash = params[param].select{|_,value|value.present?}
          if con_hash.present?
            like_con = con_hash.extract!(*(like_ary.collect{|item| item.to_s} & con_hash.keys)).map{|k,v| ["#{k} like ?","%#{v}%"] }.transpose if like_ary.present?
            like_con = [like_con.first.join(" and "),like_con.last].flatten if like_con.present?
            #适用于查询字段为空的情况
            con_hash.each{|k,v|con_hash[k] = nil if v == 'null'}

            #Rails.logger.info(con_hash.inspect)
          end
        end
        [con_hash,like_con]
      end

    end

    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end
