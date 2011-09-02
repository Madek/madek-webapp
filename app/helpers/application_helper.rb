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
        auto_link(h, :href_options => { :target => '_blank' })
    end
  end
  
  ######## Icon #########

  def icon_tag(icon)
    image_tag("icons/#{icon}.png", :style => "vertical-align: middle;")
  end


  ######## Editable #########

  def prevent_leaving_page
    javascript_tag do
      begin
      <<-HERECODE
        var isUnsavedChange = false;
        window.onbeforeunload = function(){
          if( isUnsavedChange ){
                 return "#{_("Sind Sie sicher? Aenderungen werden nicht gespeichert.")}";
          }
        }
        $(document).ready(function () {
          $("form[method='post']").submit(function(evt) {
            isUnsavedChange = false;
          });

          $("form[method='post']").change(function(evt) {
            var source = $(evt.target);
            if(source.hasClass("placeholder")){
              isUnsavedChange = false;
            }else{
              isUnsavedChange = true;
            }
          });
        });
      HERECODE
      end.html_safe
    end
  end

end
