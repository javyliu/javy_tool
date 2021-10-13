module JavyTool
  module ConstructQuery
      protected

      #like_ary：需要作like查询的字段，数组类型
      #model_class: 查询的类名，字符串类型
      #param: 查询参数,为空的话默认用model_class参数的underscore版本
      #返回数组 [普通条件，like条件]
      def construct_condition(model_class,like_ary: [],left_like:[],right_like:[],param: nil,gt:[],lt:[])
        model_class = model_class.to_s
        _class = model_class.classify.constantize
        param =  param || model_class.underscore
        #instance variable need to be remove
        #_obj = _class.send(:new,params[param])
        #self.instance_variable_set("@#{param}", _obj)

        if params[param]

          con_hash = params[param].permit!.to_hash.select{|_,value|value.present?}
          if con_hash.present?
            _like_con = con_hash.extract!(*(like_ary.collect{|item| item.to_s} & con_hash.keys)).map{|k,v| ["#{k} like ?","%#{v}%"] } if like_ary.present?
            _left_like_con = con_hash.extract!(*(left_like.collect{|item| item.to_s} & con_hash.keys)).map{|k,v| ["#{k} like ?","#{v}%"] } if left_like.present?
            _right_like_con = con_hash.extract!(*(right_like.collect{|item| item.to_s} & con_hash.keys)).map{|k,v| ["#{k} like ?","#{v}%"] } if right_like.present?

            if gt.present?
              gt.collect!(&:to_s)
              gt = (gt + gt.map{|item| "gt_#{item}"}) & con_hash.keys
              _gt_con=con_hash.extract!(*gt).map{|k,v| ["#{k.sub(/^gt_/,'')} >= ?",v] }
            end
            if lt.present?
              lt.collect!(&:to_s)
              lt = (lt + lt.map{|item| "lt_#{item}"}) & con_hash.keys
              _lt_con= con_hash.extract!(*lt).map{|k,v| ["#{k.sub(/^lt_/,'')} <= ?",v] }
            end

            all_ary_con = ((_left_like_con || [])+(_right_like_con || [])+(_like_con || [])+(_gt_con||[])+(_lt_con||[])).transpose
            all_ary_con = [all_ary_con.first.join(" and "),all_ary_con.last].flatten if all_ary_con.present?
            #适用于查询字段为空的情况
            con_hash.each{|k,v|con_hash[k] = nil if v == 'null'}

            #Rails.logger.info(con_hash.inspect)
          end
        end
        [con_hash.presence || nil,all_ary_con]
      end


  end
end
