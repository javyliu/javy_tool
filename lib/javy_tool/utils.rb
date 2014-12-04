module JavyTool
  module Utils
    require "ostruct"
    require "active_support"
    module_function

    #get user agent
    def which_os(req)
      case req
      when /(Android)\s+([\d.]+)/
        "android"
      when /(iPad).*OS\s([\d_]+)|iTunes-iPad/
        "ipad"
      when /(iPhone\sOS)\s([\d_]+)|iTunes-iPhone|iTunes-iPod/
        "iphone"
      when /TouchPad/
        "touchpad"
      when /(webOS|hpwOS)[\s\/]([\d.]+)/
        "webos"
      when /WebKit\/([\d.]+)/
        "webkit"
      end
    end

    #judge user agent
    def webkit?(req)
      !!(/WebKit\/([\d.]+)/ =~ req)
    end
    def android?(req)
      !!(/(Android)\s+([\d.]+)/ =~ req)
    end
    def ipad?(req)
      !!(/(iPad).*OS\s([\d_]+)/ =~ req)
    end
    def iphone?(req)
      !ipad?(req) && !!(/(iPhone\sOS)\s([\d_]+)|iTunes-iPhone|iTunes-iPod/ =~ req)
    end
    def ios?(req)
      ipad?(req) || iphone?(req)
    end
    def webos?(req)
      !!(/(webOS|hpwOS)[\s\/]([\d.]+)/ =~ req)
    end
    def touchpad?(req)
      webos?(req) && !!(/TouchPad/ =~ req)
    end
    # translate a Hash object to a OpenStruct object
    # parameter:
    # ahash => Hash
    # return: a OpenStruct object
    def h2o( ahash )
      return ahash unless Hash === ahash
      OpenStruct.new( Hash[ *ahash.inject( [] ) { |a, (k, v)| a.push(k, h2o(v)) } ] )
    end

    # truncate string with utf-8 encoding
    def truncate_u(text, length = 30, truncate_string = "...")
      l=0
      char_array=text.unpack("U*")
      char_array.each_with_index do |c,i|
        l = l+ (c<127 ? 0.5 : 1)
        if l>=length
          return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
        end
      end
      return text
    end

    # truncate string and chinese is two chars
    def truncate_o(text,length=16)
      text = Iconv.conv("gb2312","utf8",text)[0,length]
      Iconv.conv("utf8","gb2312",text)
    end


    #用于抽奖
    #传入代表中奖概率的数组如 1,10,20,30,40
    #返回数组的索引
    # 真实场景
    # 奖项数组
    # prize_arr =[
    # ['id'=>1,'prize'=>'平板电脑','v'=>1],
    # ['id'=>2,'prize'=>'数码相机','v'=>5],
    # ['id'=>3,'prize'=>'音箱设备','v'=>10],
    # ['id'=>4,'prize'=>'4G优盘','v'=>12],
    # ['id'=>5,'prize'=>'10Q币','v'=>22],
    # ['id'=>6,'prize'=>'下次没准就能中哦','v'=>50],
    # ]
    #
    # 传给loggery的数组应为 1,5,10,12,22,50
    # 返回的索引值即代表奖品的索引值

    def lottery(*args)
      args.extract_options!
      total = args.inject{|sum,item|sum+=item}

      args.flattern.each_with_index do |item,index|
        rand_num = rand(1..total)#.tap{|it|puts "--------#{it}"}
        if rand_num <= item
         return index
        else
          total -= item
        end
      end
    end

    # upload file,default to /tmp
    # return filename
    def upload_file(file,path=nil)
      path ||= JavyTool.options[:upload_path]
      unless file.original_filename.empty?
        filename = if block_given?
          yield file.original_filename
        else
          Time.now.strftime("%Y%m%d%H%M%S") + rand(10000).to_s + File.extname(file.original_filename)
         # if File.extname(file.original_filename).downcase == ".apk"
         #            file.original_filename.gsub(/[^\w]/,'') #
         # end
        end
        File.open(path+filename, "wb") { |f| f.write(file.read) }
        filename
      end
    end
  end
end
