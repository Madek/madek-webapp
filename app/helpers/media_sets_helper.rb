# -*- encoding : utf-8 -*-
module MediaSetsHelper

  def media_set_title(media_set, with_link = false, with_main_thumb = false, total_thumbs = 0, accessible_resource_ids = nil)
    content = capture_haml do
      div_class, thumb_class = media_set.is_a?(Media::Project) ? ["set-box project-box", "thumb_box_project"] : ["set-box", "thumb_box_set"]
      haml_tag :div, :class => div_class do
        haml_tag :div, thumb_for(media_set, :small_125), :class => thumb_class if with_main_thumb
        haml_tag :br
        haml_tag :span, media_set.title, :style => "font-weight: bold; font-size: 1.2em;"
        #2001# " (%d/%d Medieneinträge)" % [visible_media_entries.count, media_set.media_entries.count]
        haml_concat " (%d Medieneinträge)" % [media_set.media_entries.count]
        haml_tag :br
        haml_concat "von #{media_set.user}"
        haml_tag :br
        if total_thumbs > 0
          haml_tag :br
          ids = (media_set.media_entry_ids & accessible_resource_ids)[0, total_thumbs]
          media_entries = media_set.media_entries.find(ids).paginate
          if media_entries.empty?
            haml_tag :small, _("Noch keine Medieneinträge enthalten")
          else
            media_entries.each do |media_entry|
              haml_tag :div, thumb_for(media_entry, :small), :class => "thumb_mini" 
            end
            haml_concat "..." if media_entries.total_pages > media_entries.current_page
          end
        end
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
          div_class, thumb_class = media_set.is_a?(Media::Project) ? ["set-box project-box", "thumb_box_project"] : ["set-box", "thumb_box_set"]
          haml_tag :div, :class => div_class, :title => media_set.to_s do
            haml_tag :a, thumb_for(media_set, :small_125), :href => media_set_path(media_set), :class => thumb_class
          end
        end
        script = javascript_tag do
          begin
          <<-HERECODE
            $(document).ready(function () {
              $(".set-box[title]").qtip({
                position: {
                  my: 'bottom center',
                  at: 'top center'
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
          #2001# media_entries = media_set.media_entries.select {|media_entry| Permission.authorized?(current_user, :view, media_entry)}
          #2001# media_set_title(media_set, media_entries, true)
          haml_concat media_set_title(media_set, true, true)
        end
      end
    end
  end

  def media_sets_setter(form_path, with_cancel_button = false)
    form_tag form_path, :id => "set_media_sets" do
      b = content_tag :h3, :style => "clear: both" do
        _("Zu Set/Projekt hinzufügen:")
      end

      b += content_tag :span, :style => "margin-right: 1em;" do
        select_tag "media_set_ids[]", options_for_select({_("- Auswählen -") => nil}) + options_from_collection_for_select(Media::Set.accessible_by(current_user, :edit), :id, :title_and_user), :style => "width: 100%;"
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
        submit_tag _("Zu ausgewähltem Set/Projekt hinzufügen…"), :style => "display: none; float: right; margin: 20px 0;"
      end
      
      b += content_tag :p, :style => "clear: both;" do
        link_to _("Weiter ohne Hinzufügen zu einem Set/Projekt…"), root_path, :class => "upload_buttons"
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
# TODO move to media_projects_helper.rb ??

  def display_project_abstract_slider(project, total_entries)
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
                  complete: function(response){ $("#slider").nextAll(".meta_data:first").replaceWith(response.responseText); }
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

  def display_project_abstract(project, min_media_entries, accessible_media_entry_ids)
    meta_data = project.abstract(min_media_entries, accessible_media_entry_ids)
    capture_haml do
      haml_tag :div, :class => "meta_data" do
        if meta_data.blank?
          haml_concat _("Es sind nicht genügend Werte für einen Projekt-Auszug vorhanden.")
        else
          contexts = project.individual_contexts
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

  def display_project_vocabulary(project, accessible_media_entry_ids)
    used_meta_term_ids = project.used_meta_term_ids(accessible_media_entry_ids)
    capture_haml do
      haml_tag :p do
        haml_concat "Für dieses Projekt wurde ein spezifisches Vokabular erstellt."
        haml_tag :p
          haml_tag :a, "Zeige die bereits vergebenen Werte", :href => "#", :id => "terms_toggler"
      end
      haml_tag :br
      
      project.individual_contexts.each do |context|
        haml_tag :h3, context
        haml_tag :p, context.description
        context.meta_keys.for_meta_terms.each do |meta_key|
          definition = meta_key.meta_key_definitions.for_context(context)
          haml_tag :h4, definition.meta_field.label
          haml_tag :div, :class => "columns_3" do
            meta_key.meta_terms.each do |meta_term|
              is_used = used_meta_term_ids.include?(meta_term.id)
              haml_tag :p, meta_term, :"data-meta_term_id" => meta_term.id, :"data-used" => (is_used ? 1 : 0)
            end
          end
        end
      end

      script = javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function () {
            var unused_terms = $("p[data-meta_term_id][data-used='0']");
            var terms_toggler = $("a#terms_toggler");
            terms_toggler.data("active", false);             
            terms_toggler.click(function(){
              var that = $(this);
              if(that.data("active")){
                unused_terms.removeClass("disabled");
                that.html("Zeige die bereits vergebenen Werte");
                that.data("active", false);
              }else{
                unused_terms.addClass("disabled");
                that.html("Zeige das gesamte Vokabular");
                that.data("active", true);
              }
              return false;
            });
          });
        HERECODE
        end.html_safe
      end
      haml_concat script
      
    end
  end

end
