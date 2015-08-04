module JavyTool
  module Breadcrumb
    module ClassMethods

    end

    module InstanceMethods
      protected

      def set_breadcrumbs
        @breadcrumbs = ["#{I18n.t("common.index_icon")}<a href='/'>#{I18n.t("common.home")}</a>".html_safe]
      end

      def drop_breadcrumb(title=nil, url=nil)
        title ||= @page_title
        if title
          if url
            @breadcrumbs.push("<a href=\"#{url}\">#{title}</a>".html_safe)
          else
            @breadcrumbs.push("#{title}")
          end
        end
      end

      def drop_page_title(title)
        @page_title = title
        return @page_title
      end

      def no_breadcrumbs
        @breadcrumbs = []
      end
    end

    module Helpers
      def yield_or_default(message, default_message = "")
        message.nil? ? default_message : message
      end
      # set SITE_NAME in enviroment.rb
      # set @page_title in controller respectively
      # add<%= render_page_title %> in head
      def render_page_title
        title = @page_title ? "#{@page_title}_#{SITE_NAME}" : SITE_NAME rescue "SITE_NAME"
        content_tag("title", title, nil, false)
      end

      def render_body_tag
        class_attribute = ["#{controller_name}-controller","#{action_name}-action"].join(" ")
        id_attribute = (@body_id)? " id=\"#{@body_id}-page\"" : ""
        raw(%Q[ <body#{id_attribute} class="#{class_attribute}"> ])
      end


      # display the flash messages using foundation
      def notice_message
        flash_messages = []
        flash.each do |type, message|
          next if message.nil?
          type = :info if type == :notice
          type = :alert if type == :error
          text = content_tag(:div, message.html_safe, class: "alert-box #{type}")
          flash_messages << text if message
        end
        flash_messages.join("\n").html_safe
      end

      def s(html)
        sanitize( html, :tags => %w(table thead tbody tr td th ol ul li div span font img sup sub br hr a pre p h1 h2 h3 h4 h5 h6), :attributes => %w(id class style src href size color) )
      end

      def render_breadcrumb
        return "" if @breadcrumbs.nil? || @breadcrumbs.size <= 0
        prefix = "".html_safe
        crumb = []#.html_safe

        @breadcrumbs.each_with_index do |c, i|
          breadcrumb_class = []
          breadcrumb_class << "current" if i == (@breadcrumbs.length - 1)

          crumb.push content_tag(:li, c ,:class => breadcrumb_class )
        end
        return prefix + content_tag(:ul, crumb.join("").html_safe, :class => "breadcrumbs")
      end

      # add nested object to the parent form by ajax
      # parameters:
      # name: link title
      # f: form_for's f
      # association: association object
      # example:
      # <%=link_to_add_fields("Add Cycle",f,:pipgame_cycles,f.object.pipgame_cycles.new(:item_type => "App",:position => "cycle_img")) %>
      # this method will render _pipgame_cycle_fields.html.erb file like
      #
      #  <div class="fields" rel="need_upload">
      #    <p>
      #    <%= f.label :img_src %><br />
      #    <%= f.hidden_field :img_src,:class=>"web_img_src" %>
      #    <%= f.hidden_field :item_type %>
      #    <%= f.hidden_field :position %>
      #    <%= f.hidden_field :_destroy %>
      #    <%= link_to_function "remove", "remove_fields(this)" %>
      #    </p>
      #  </div>
      #
      # and you need add javascript like following:
      #
      #  function remove_fields(link) {
      #   $(link).prev("input[type=hidden]").val("1");
      #   $(link).closest(".fields").hide();
      #  }
      #  function add_fields(link, association, content) {
      #   var new_id = new Date().getTime();
      #   var regexp = new RegExp("new_" + association, "g");
      #   var con = content.replace(regexp, new_id);
      #   //console.log(con);
      #   $(link).parent().before(con);
      #  }
      #
      #  deprecated in rails4 need to fix the link_to_founction
      #  Fixed:
      ### Need change the association_fields like following:
      #
      #  <div class="fields" rel="need_upload">
      #    <p>
      #    <%= f.label :img_src %><br />
      #    <%= f.hidden_field :img_src,:class=>"web_img_src" %>
      #    <%= f.hidden_field :item_type %>
      #    <%= f.hidden_field :position %>
      #    <%= f.hidden_field :_destroy %>
      #    <%= link_to "remove_fields", "#" %>
      #    </p>
      #  </div>
      #
      ### Need add code to application.js like following:
      #
      #  $(document).bind("click",".add_fields",function(e){
      #    e.preventDefault();
      #    var _this = $(this);
      #    var new_id = new Date().getTime();
      #    var regexp = new RegExp("new_" + _this.data("association"), "g");
      #    var con = _this.data("content").replace(regexp, new_id);
      #    $(this).parent().before(con);
      #  }).bind("click",".remove_fields",function(e){
      #    e.preventDefault();
      #    var _this = $(this);
      #    _this.prev("input[type=hidden]").val("1");
      #    _this.closest(".fields").hide();
      #
      #  });
      #
      #
      def link_to_add_fields(name, f, association,new_object=nil,options={})
        new_object ||= f.object.class.reflect_on_association(association).klass.new()
        fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
          render(association.to_s.singularize + "_fields", :f => builder)
        end
        options.merge!(data: {association: association,content: escape_javascript(fields.html_safe)},class: "add_fields")
        link_to(name,"#",options)
      end


      #set head description,keywords etc
      def head(head_identity=nil)
        content_for(:head) do
          case head_identity
          when "description"
            "<meta name=\"description\" content=\"#{yield}\" />\n"
          when "keywords"
            "<meta name=\"keywords\"  content=\"#{yield}\" />\n"
          else
            yield
          end.html_safe
        end
      end
      #add javascript to foot
      def foot
        content_for(:foot) do
          yield.html_safe
        end
      end
      #format time
      def format_timestamp(ts,format='%Y-%m-%d %H:%M')
        ts.strftime(format)
      end
    end

    def self.included(receiver)
      #receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :helper, Helpers
      receiver.send (Rails::VERSION::MAJOR > 3 ? :before_action : :before_filter), :set_breadcrumbs
    end
  end
end
