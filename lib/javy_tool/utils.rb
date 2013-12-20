module JavyTool
  module Utils
    require "ostruct"
    module_function
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
