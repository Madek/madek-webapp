# -*- encoding : utf-8 -*-
module ApplicationHelper
  
  ######## Flash #########

  def flash_helper
    fc = flash_content
    content_tag :div, :class => "container_12 clearfix", :id => "flash" do
      fc
    end unless fc.blank?
  end

  def flash_content
    r = "".html_safe
    [:notice, :error].each do |f|
      r += content_tag :div, :class => "grid_12 #{f}" do
        to_list(flash[f])
      end unless flash[f].blank?
    end
    flash.discard if flash
    r
  end

  ######## Hash/Array to <ul> list #########

  def to_list(h)
    case h.class.name
      when "Hash"
          r = "".html_safe
          h.each_pair do |key,value|
              r += "#{key}: #{to_list(value)}"
          end
          r
      when "Array"
        content_tag :ul, :style => "padding-left: 1em;" do
          r = "".html_safe
          h.each do |value|
            r += content_tag :li do
              to_list(value)
            end
          end
          r
        end
      else
        auto_link(html_escape(h), :html => {:target => '_blank', :rel => 'nofollow'})
    end
  end
  
end
