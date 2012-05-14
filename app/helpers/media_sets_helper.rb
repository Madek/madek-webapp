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
          media_entries = media_set.media_entries.accessible_by_user(current_user).order("media_resources.updated_at DESC").paginate(:page => 1, :per_page => total_thumbs)
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
          #2001# media_entries = media_set.media_entries.select {|media_entry| current_user.authorized?(:view, media_entry)}
          #2001# media_set_title(media_set, media_entries, true)
          haml_concat media_set_title(media_set, true, true)
        end
      end
    end
  end

  def media_sets_widget(resources = nil, linked_content = nil, more_class = nil, linked_index_with = {})
    resources = Array(resources)
    capture_haml do
      if resources.empty?
        selected_ids = ""
        detach_selected = "true"
        link = {path: "/media_resources/parents.json", method: "POST", data: {parent_media_set_ids: ":parent_media_set_ids", media_resource_ids: ":media_resource_ids"}}
        unlink = {path: "/media_resources/parents.json", method: "DELETE", data: {parent_media_set_ids: ":parent_media_set_ids", media_resource_ids: ":media_resource_ids"}}
      else
        selected_ids = resources.map(&:id).to_json
        if resources.first.is_a?(MediaSet)
          detach_selected = "true"
          link = {path: "/media_sets/parents.json", method: "POST", data: {parent_media_set_ids: ":parent_media_set_ids", media_set_ids: ":media_set_ids"}}
          unlink = {path: "/media_sets/parents.json", method: "DELETE", data: {parent_media_set_ids: ":parent_media_set_ids", media_set_ids: ":media_set_ids"}}
        else
          detach_selected = nil
          link = {path: "/media_entries/media_sets.json", method: "POST", data: {parent_media_set_ids: ":parent_media_set_ids", media_entry_ids: ":media_entry_ids"}}
          unlink = {path: "/media_entries/media_sets.json", method: "DELETE", data: {parent_media_set_ids: ":parent_media_set_ids", media_entry_ids: ":media_entry_ids"}}
        end
      end
      args = {title: _("Zu Set hinzufügen/entfernen"),
              class: ("has-set-widget"+" #{more_class}"),
              :"data-selected_ids" => selected_ids,
              :"data-user" => current_user.to_json(only: {}, methods: :name),
              :"data-after_submit" => "window.location.reload();",
              :"data-detach_selected" => detach_selected,
              :"data-index" => {path: "/media_sets.json", method: "GET", data: {accessible_action: "edit", with: {meta_data: {meta_key_names: ["title", "creator"]}, created_at: 1}}}.to_json,
              :"data-linked_index" => {path: "/media_sets.json", method: "GET", data: {accessible_action: "edit", child_ids: ":selected_ids"}.merge(linked_index_with), with: {children: 1}}.to_json,
              :"data-create" => {path: "/media_sets.json", method: "POST", data: {media_sets: ":created_items"}, created_item: {meta_data_attributes: {0 => {meta_key_label: "title", value: ":title"}}}}.to_json,
              :"data-link" => link.to_json,
              :"data-unlink" => unlink.to_json}
  
      haml_tag :button, args do
        if linked_content
          haml_concat linked_content
        else
          haml_tag :div, :class => "button_addto"
        end
      end
    end
  end

####################################################################
# TODO merge with meta_contexts_helper ?? 

  def display_set_abstract_slider(set, total)
    capture_haml do
      haml_tag :p, :style => "padding: 1.8em;" do
        haml_tag :span, :id => "amount", :style => "color: #444444; font-weight: bold; position: absolute;"
      end
      haml_tag :div, :id =>"slider", :style => "border: 1px solid #DDDDDD;"
      
      script = javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function () {
            var total = #{total}; 
            function update_amount(ui){
              var l = ui.find("a").css('left');
              var v = ui.slider( "value" ) + " von " + total;
              $("#amount").html(v).css('left', l);
            }
            $("#slider").slider({
              value: #{total * 30 / 100},
              min: 1,
              max: total,
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
            haml_tag :h4, definition.label
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
