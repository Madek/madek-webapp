# -*- encoding : utf-8 -*-
module MediaSetsHelper

  def media_set_title(media_set, with_link = false, with_main_thumb = false, total_thumbs = 0)
    content = capture_haml do
      div_class, thumb_class = ["set-box", "thumb_box_set"]
      haml_tag :div, :class => div_class do
        haml_tag :div, thumb_for(media_set, :small_125), :class => thumb_class if with_main_thumb
        haml_tag :br
        haml_tag :span, media_set.title, :style => "font-weight: bold; font-size: 1.2em;"
        #2001# " (%d/%d Medieneinträge)" % [visible_media_entries.count, media_set.media_entries.count]
        haml_concat " (%d Medieneinträge)" % [media_set.media_entries.count]
        haml_tag :br
        unless (authors = media_set.meta_data.get_value_for("author")).blank?
          haml_concat "von #{authors}"
          haml_tag :br
        end
        if total_thumbs > 0
          haml_tag :br
          media_entries = media_set.media_entries.accessible_by_user(current_user).paginate(:page => 1, :per_page => total_thumbs)
          if media_entries.empty?
            haml_tag :small, _("Noch keine Medieneinträge enthalten")
          else
            media_entries.each do |media_entry|
              haml_tag :div, thumb_for(media_entry, :small), :class => "thumb_mini" 
            end
            haml_concat "..." if media_entries.total_pages > media_entries.current_page
          end
        end
        haml_tag :div, :class => "clearfix"
      end
    end

    capture_haml do
      if with_link
        haml_tag :a, content, :href => media_set_path(media_set)
      else
        haml_concat content
      end
    end
  end

  def media_sets_list(media_sets, with_tooltip = false)
    capture_haml do
      if with_tooltip
        media_sets.each do |media_set|
          div_class, thumb_class = ["set-box", "thumb_box_set"]
          haml_tag :div, :class => div_class, :title => media_set.to_s do
            haml_tag :a, thumb_for(media_set, :small_125), :href => media_set_path(media_set), :class => thumb_class
          end
        end
        haml_tag :style do
          haml_concat ".ui-tooltip { font-size: 1.1em; line-height: normal; }"
        end
        script = javascript_tag do
          begin
          <<-HERECODE
            $(document).ready(function () {
              $(".set-box[title]").qtip({
                position: {
                  my: 'bottom center',
                  at: 'top center',
                  viewport: $(window)
                },
                style: {
                   classes: 'ui-tooltip-youtube ui-tooltip-shadow'
                }
              });
            });
          HERECODE
          end.html_safe
        end
        haml_concat script
      else
        haml_tag :h4, _("Enthalten in")
        media_sets.each do |media_set|
          #2001# media_entries = media_set.media_entries.select {|media_entry| Permissions.authorized?(current_user, :view, media_entry)}
          #2001# media_set_title(media_set, media_entries, true)
          haml_concat media_set_title(media_set, true, true)
        end
      end
    end
  end

  def media_sets_setter(form_path, with_cancel_button = false)
    editable_sets = MediaResource.accessible_by_user(current_user, :edit).media_sets
    form_tag form_path, :id => "set_media_sets" do
      b = content_tag :h3, :style => "clear: both" do
        _("Zu Set hinzufügen:")
      end

      b += content_tag :span, :style => "margin-right: 1em;" do
        select_tag "media_set_ids[]", options_for_select({_("- Auswählen -") => nil}) + options_from_collection_for_select(editable_sets, :id, :title_and_user), :style => "width: 100%;"
      end

      b += content_tag :button, :id => "new_button", :style => "float: left;" do
            _("Neues Set erstellen")
      end

      b += content_tag :span, :id => "text_media_set", :style => "display: none;" do
        c = text_field_tag nil, nil, :style => "width: 20em; margin-top: 0; float: left;"
        c += content_tag :button, :style => "margin: 0 0 0 10px;" do
              _("Hinzufügen")
        end
      end

      b += content_tag :p, :style => "clear: right; margin-bottom: 15px; font-size:1.2em;", :class => "save" do
        submit_tag _("Zu ausgewähltem Set hinzufügen…"), :style => "display: none; float: right; margin: 20px 0;"
      end
      
      b += content_tag :p, :style => "clear: both;" do
        link_to _("Weiter ohne Hinzufügen zu einem Set…"), root_path, :class => "upload_buttons"
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

####################################################################
# TODO merge with meta_contexts_helper ?? 

  def display_set_abstract_slider(set, total_entries)
    capture_haml do
      haml_tag :p, :style => "padding: 1.8em;" do
        haml_tag :span, :id => "amount", :style => "color: #444444; font-weight: bold; position: absolute;"
      end
      haml_tag :div, :id =>"slider", :style => "border: 1px solid #DDDDDD;"
      
      script = javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function () {
            var total_entries = #{total_entries}; 
            function update_amount(ui){
              var l = ui.find("a").css('left');
              var v = ui.slider( "value" ) + " von " + total_entries;
              $("#amount").html(v).css('left', l);
            }
            $("#slider").slider({
              value: #{total_entries * 30 / 100},
              min: 1,
              max: total_entries,
              step: 1,
              create: function( event, ui ) { update_amount($(this)); },
              slide: function( event, ui ) { update_amount($(this)); },
              change: function( event, ui ) {
                update_amount($(this));
                $.ajax({
                  url: "#{abstract_media_set_path(@media_set)}",
                  data: {value: ui.value},
                  complete: function(response){
                    $("#slider").nextAll(".meta_data:first").replaceWith(response.responseText);
                    browsing_document_ready();
                  }
                });
              }
            });
          });
        HERECODE
        end.html_safe
      end
      haml_concat script

    end
  end

  def display_set_abstract(set, min_media_entries, current_user)
    meta_data = set.abstract(min_media_entries, current_user)
    capture_haml do
      haml_tag :div, :class => "meta_data" do
        if meta_data.blank?
          haml_concat _("Es sind nicht genügend Werte für einen Set-Auszug vorhanden.")
        else
          contexts = set.individual_contexts
          meta_data.collect do |meta_datum|
            meta_datum.meta_key.reload #tmp# TODO remove this line, is an Identity Map problem ??
            context = contexts.detect {|c| meta_datum.meta_key.meta_contexts.include?(c) }
            next unless context
            definition = meta_datum.meta_key.meta_key_definitions.for_context(context)
            haml_tag :h4, definition.meta_field.label
            haml_tag :p, preserve(formatted_value(meta_datum))
          end
        end
      end
    end
  end

  def display_set_vocabulary(set, current_user)
    used_meta_term_ids = set.used_meta_term_ids(current_user)
    vocabulary_json = set.individual_contexts.map {|context| context.vocabulary(current_user, used_meta_term_ids).as_json }
    capture_haml do
      haml_tag :p do
        haml_concat "Für dieses Set wurde ein spezifisches Vokabular erstellt."
      end
      haml_concat display_contexts_vocabulary(vocabulary_json)
    end
  end

end
