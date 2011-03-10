# -*- encoding : utf-8 -*-
module MediaSetsHelper

  #2001# def media_set_title(media_set, visible_media_entries, with_link = false)
  def media_set_title(media_set, with_link = false)
    content_tag :div, :class => "sidebar-box" do
      r = content_tag :span, :style => "font-weight: bold;" do 
        with_link ? link_to(media_set.title, media_set_path(media_set)) : media_set.title
      end
      #2001# r += " (%d/%d Medieneinträge)" % [visible_media_entries.count, media_set.media_entries.count]
      r += " (%d Medieneinträge)" % [media_set.media_entries.count]
      r += tag :br
      r += "von #{media_set.user}"
    end
  end

  def media_sets_list(media_sets)
    a = content_tag :h3, :style => "margin-top: 1em; padding-left: 12px;" do
      "Sets"
    end
    media_sets.each do |media_set|
      #2001# media_entries = media_set.media_entries.select {|media_entry| Permission.authorized?(current_user, :view, media_entry)}
      #2001# a += media_set_title(media_set, media_entries, true)
      a += media_set_title(media_set, true)
    end
    a
  end


  def media_sets_setter(form_path, with_cancel_button = false)
    form_tag form_path, :id => "set_media_sets" do
      b = content_tag :h2, :style => "clear: both" do
        _("Sets")
      end

      b += content_tag :span, :style => "margin-right: 1em;" do
        select_tag "media_set_ids[]", options_for_select({_("- Auswählen -") => nil}) + options_from_collection_for_select(current_user.editable_sets, :id, :title_and_user), :style => "width: 40%;"
      end

      b += content_tag :button, :id => "new_button" do
            _("Neu")
      end

      b += content_tag :span, :id => "text_media_set", :style => "display: none;" do
        c = text_field_tag nil, nil, :style => "width: 15em;"
        c += content_tag :button do
              _("Hinzufügen")
        end
      end

      b += content_tag :p, :style => "margin: 1em 0 0 0" do
        submit_tag _("Gruppierungseinstellungen speichern"), :style => "display: none;"
      end
      
      b += content_tag :p, :style => "margin: 1em 0 0 0" do
        link_to _("Weiter ohne Gruppierung"), root_path, :class => "buttons"
      end if with_cancel_button

      b += javascript_tag do
        begin
        <<-HERECODE
        $(document).ready(function () {
          $("button#new_button").click(function() {
            $(this).hide();
            $(this).closest("form").find("input:submit").hide();
            $("#text_media_set input").val("");
            $("#text_media_set").fadeIn();
            return false;
          });
          $("#text_media_set button").click(function() {
            var v = $("#text_media_set input").val();
            $("#media_set_ids_").append("<option value='"+v+"' selected='selected'>"+v+"</option>");
            $("#text_media_set").hide();
            $("button#new_button").fadeIn();
            $("form#set_media_sets").trigger('change');
            return false;
          });
          $("#text_media_set input").keypress(function(event) {
            if(event.keyCode == 13){ // 13 is Enter
              $("#text_media_set button").trigger('click');
              return false;
            }
          });
          
          $("form#set_media_sets").change(function() {
            $(this).find("input:submit").show();
          });
        });
        HERECODE
        end.html_safe
      end

    end

  end

end
