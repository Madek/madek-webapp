# -*- encoding : utf-8 -*-
module MetaDataHelper

  def display_meta_data_helper(title, values)
    capture_haml do
      haml_tag :ul do
        haml_tag :li, :class=>"meta_group" do
          haml_tag :h4, title, :class=>"meta_group_name"
            haml_tag :ul do
            if values.blank?
              haml_tag :li, _("Es sind keine Metadaten zu diesem Kontext bereit gestellt."), :class=>"meta_data_comment"
            else
              values.each do |value|
                haml_tag :li, :class=>"meta_vocab" do
                  haml_tag :h5, value.first, :class=>"meta_vocab_name"
                  haml_tag :span, :class => "meta_terms" do
                    haml_concat value.last.gsub(/\S\,\S/,", ")
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def display_meta_data_for(resource, context)
    h = {}
    meta_data = resource.meta_data_for_context(context, false)
    meta_data.each do |meta_datum|
      next if meta_datum.to_s.blank? #tmp# OPTIMIZE 2007
      definition = meta_datum.meta_key.meta_key_definitions.for_context(context)
      h[definition.label.to_s] = formatted_value(meta_datum) 
    end
    display_meta_data_helper(context, h)
  end
  
  def display_objective_meta_data_for(resource)
    meta_data = [["Filename", resource.media_file.filename]]
    meta_data += resource.media_file.meta_data_without_binary.sort
    display_meta_data_helper(_("Datei"), meta_data)
  end

  def display_activities_for(media_entry, is_expert = false)
    meta_data = []
    meta_data << [_("Hochgeladen von"), link_to(media_entry.user, media_resources_path(:query => media_entry.user.fullname))]
    meta_data << [_("Hochgeladen am"), _("%s Uhr") % media_entry.created_at.to_formatted_s(:date_time)]

    unless (edit_sessions = media_entry.edit_sessions.limit(5)).empty?
      meta_data << [_("Letzte Aktualisierung"), edit_sessions.map do |edit_session|
                                                  "#{link_to(edit_session.user, edit_session.user)} / #{_("%s Uhr") % edit_session.created_at.to_formatted_s(:date_time)}"
                                                end.join('<br>') ]
    end

    unless (description_author_before_import = media_entry.meta_data.get_value_for("description author before import")).blank?
      meta_data << [_("Beschreibung durch (vor dem Hochladen ins Medienarchiv)"), description_author_before_import]
      unless media_entry.snapshots.empty?
        meta_data << [_("MIZ-Archiv Kopie"), "#{_("%s Uhr") % media_entry.snapshots.first.created_at.to_formatted_s(:date_time)}"]
      end
    end

    if is_expert
      unless media_entry.snapshots.empty?
        date = media_entry.snapshots.first.created_at.to_formatted_s(:date)
        time = media_entry.snapshots.first.created_at.to_formatted_s(:time)
        meta_data << ["", "Eine Kopie dieses Medieneintrages wurde am #{date} um #{time} Uhr für das MIZ-Archiv erstellt."]
      end
      unless media_entry.snapshotable?
        meta_data << ["", _("Diese Kopie wird gegenwärtig durch das MIZ-Archiv bearbeitet.")]
      end
    end
    
    display_meta_data_helper( _("Aktivitäten"), meta_data)
  end
  
  #####################################################################################
  
  def display_meta_data_for_context(resource, context)
    capture_haml do
      uploader_info, other_info = resource.meta_data_for_context(context).partition {|md| ["uploaded by", "uploaded at"].include?(md.meta_key.label) }
      other_info.each do |meta_datum|
        definition = meta_datum.meta_key.meta_key_definitions.for_context(context)
        haml_tag :h4, definition.label.to_s
        if meta_datum.meta_key.label == "title"
          haml_tag :h3, formatted_value(meta_datum)
        else
          haml_tag :p, preserve(formatted_value(meta_datum))
        end
      end
    end
  end

  def formatted_value_for_people(people)
    s = people.map do |p|
      next unless p
      #temp# link_to p, p
      link_to p, media_resources_path(:query => p.fullname)
    end
    s.join('<br />').html_safe
  end

  # TODO merge with MetaDatum#to_s
  def formatted_value(meta_datum)
    
    case meta_datum.meta_key.meta_datum_object_type
      when "MetaDatumPeople", "MetaDatumUsers"
        formatted_value_for_people(Array(meta_datum.deserialized_value))
      when "MetaDatumKeywords"
        s = Array(meta_datum.deserialized_value).map do |v|
          next unless v
          link_to v, media_resources_path(:query => v.to_s)
        end
        s.join(', ').html_safe
      when "MetaDatumDate"
        meta_datum.to_s.try(&:html_safe)
      when "Date"
        _("%s Uhr") % meta_datum.deserialized_value.to_formatted_s(:date_time)
      when "MetaDatumMetaTerms"
        meta_datum.deserialized_value.map do |dv|
          #old# link_to dv, filter_media_resources_path(:meta_key_id => meta_datum.meta_key, :meta_term_id => dv.id), :method => :post, :"data-meta_term_id" => dv.id #old# , :remote => true
          link_to dv, media_resources_path(:meta_key_id => meta_datum.meta_key, :meta_term_id => dv.id), :"data-meta_term_id" => dv.id
        end.join(' ')
      else
        s = meta_datum.to_s
        #(s =~ /\n/ ? simple_format(s) : s)
        #old#
        auto_link(s, :all, :target => "_blank")
        #new1# auto_link(s, :href_options => { :target => '_blank' })
        #new2# to_list(s)
    end
  end

###########################################################

  def widget_meta_terms(meta_datum, meta_key, meta_terms, ui)
    if meta_key.is_extensible_list? or meta_terms.size > 16
      widget_meta_terms_multiselect(meta_datum, meta_key)
    else
      half_size = (meta_terms.size / 2) + (meta_terms.size % 2)
      content_tag :ul, :class => "meta_terms" do
        c = content_tag :li do
          content_tag :ul do
            meta_terms[0..(half_size-1)].collect do |term|
              checkbox_for_term(term, meta_datum, ui)
            end.join.html_safe
          end
        end
        c += content_tag :li do
          content_tag :ul do
            meta_terms[half_size..-1].collect do |term|
              checkbox_for_term(term, meta_datum, ui)
            end.join.html_safe
          end
        end
      end
    end
  end

  def checkbox_for_term(term, meta_datum, ui)
    is_checked = (meta_datum.object.value and meta_datum.object.value.include?(term.id))
    content_tag :li do
      a = case ui
        when :radio_button
          radio_button_tag "#{meta_datum.object_name}[value][]", term.id, is_checked
        else
          check_box_tag "#{meta_datum.object_name}[value][]", term.id, is_checked
      end
      a += term.to_s
    end
  end

###########################################################

  def widget_meta_countries(meta_datum, meta_key)
    file = "#{Rails.root}/config/definitions/helpers/country_codes.yml"
    entries = YAML.load(File.read(file))

    all_options = entries.collect {|x| ["#{x["country_code"]} - #{x["country_name"]}", x["country_code"]]}.sort
    selected_option = meta_datum.object.value
    
    all_options << [selected_option, selected_option] unless all_options.collect{|x| x[1]}.include?(selected_option)
    
    meta_datum.select :value, options_for_select(all_options, selected_option), {:include_blank => true}
  end

###########################################################
  
  # NEW generic multi select plugin
  def widget_meta_terms_multiselect(meta_datum, meta_key)
    case meta_key.meta_datum_object_type
      when "MetaDatumMetaDepartments"
        selected = Array(meta_datum.object.value)
        departments_without_semester = 
          if SQLHelper.adapter_is_mysql?
            MetaDepartment.where("ldap_name NOT REGEXP '_[0-9]{2}[A-Za-z]\.studierende'")
          elsif SQLHelper.adapter_is_postgresql?
            MetaDepartment.where("ldap_name NOT SIMILAR TO '%_[0-9]{2}[A-Za-z]\.studierende'")
          else
            raise "adapter is not supported"
          end
        all_options = departments_without_semester.collect {|x| {:label => x.to_s, :id => x.id, :selected => selected.include?(x.id)} }
      when "MetaDatumMetaTerms"
        selected = Array(meta_datum.object.value)
        all_options = meta_key.meta_terms.collect {|x| {:label => x.to_s, :id => x.id, :selected => selected.include?(x.id)}}
      when "MetaDatumPeople"
        selected_ids = Array(meta_datum.object.value).map(&:id)
        @people ||= Person.with_meta_data
        all_options = @people.collect {|x| {:label => x.to_s, :id => x.id, :selected => selected_ids.include?(x.id)}}
      when "MetaDatumKeywords"
        keywords = meta_datum.object.deserialized_value
        meta_term_ids = keywords.collect(&:meta_term_id)
        all_grouped_keywords = 
          if SQLHelper.adapter_is_mysql?
            Keyword.group(:meta_term_id)
          elsif SQLHelper.adapter_is_postgresql?
            Keyword.select "DISTINCT ON (meta_term_id) * "
          else
            raise "adapter is not supported"
          end
        all_grouped_keywords = all_grouped_keywords.where(["meta_term_id NOT IN (?)", meta_term_ids]) unless meta_term_ids.empty?
        all_options = keywords.collect {|x| {:label => x.to_s, :id => x.meta_term_id, :selected => true}}
        all_options += all_grouped_keywords.collect {|x| {:label => x.to_s, :id => x.meta_term_id, :selected => false}}
        all_options.sort! {|a,b| a[:label].downcase <=> b[:label].downcase}
    end

    is_extensible = (meta_key.is_extensible_list? or ["MetaDatumKeywords", "MetaDatumPeople"].include?(meta_key.meta_datum_object_type))
    with_toggle = !["keywords", "author", "creator", "description author", "description author before import"].include?(meta_key.label)

    h = content_tag :div, :class => "madek_multiselect_container",
                          :"data-is_extensible" => is_extensible,
                          :"data-with_toggle" => with_toggle do 
      a = content_tag :ul, :class => "holder" do
        content_tag :li, :class => "input_holder" do
          text_field_tag "autocomplete_search", nil, :style => "outline: none; border: none;", :id => "#{meta_key.label.gsub(/\W+/, '_')}_autocomplete_search",
                          :"data-all_options" => "#{all_options.to_json}",
                          :"data-field_name_prefix" => "#{meta_datum.object_name}"
        end
      end
    end
  
        
    @js_3 ||= false
    unless @js_3
      @js_3 = true
      h += content_tag :script, :type => "text/x-jquery-tmpl", :id => "madek_multiselect_item" do
        begin
        <<-HERECODE
          <li class='bit-box'>
            ${label}
            <input type='hidden' name='${field_name_prefix}[value][]' value='${id}'>
            <a class="closebutton" href="#"></a>
          </li>
        HERECODE
        end.html_safe
      end
      h += stylesheet_link_tag "jquery/fcbkcomplete.css", "jquery/fcbkcomplete_custom.css"
      h += javascript_tag do
        begin
        <<-HERECODE
          $(document).ready(function(){
            function do_nothing() {
                  return false;
            };
            $(".dialog_link").click(function(e){
              // prevent double click on link
              $(e.target).click(do_nothing);
              setTimeout(function(){
                $(e.target).unbind('click', do_nothing);
              }, 1000);
              var source = $(this);
              var next_container = source.next();
              if(next_container.length > 0){
                next_container.slideToggle();
                source.children("img:last").toggleClass("expanded");
              }else{
                $.ajax({
                  url: source.attr("href"),
                  data: {format: 'js'},
                  dataType: 'html',
                  success: function(response){
                    source.children("img:last").toggleClass("expanded");
                    source.after(response);
                    source.next().hide().slideDown();
                    $("form[data-remote] input:submit").click(function(event){
                      $(this).closest("form").trigger("submit");
                      return false;
                    });

                    if(source.closest("[data-meta_key]").data("meta_key") == "keywords"){
                      hide_selected_keywords(source.prev(".madek_multiselect_container").find("ul.holder")); 
                    }else{
                      $("form.new_person").bind("ajax:success", function(xhr, item, status){
                        if (item.id != null) {
                          var search_field = $(this).closest("[data-meta_key]").find("input[name='autocomplete_search']");
                          add_to_selected_items(item, search_field, true);
                        };  
                        source.children("img:last").toggleClass("expanded");
                        $(this).closest(".tabs").remove();
                      });
                    }
                  }
                });
              }
              return false;                  
            });                   
          });
        HERECODE
        end.html_safe
      end
    end

    h
  end

  def field_tag(meta_datum, context, autofocus = false, with_actions = false)
    h = meta_datum.hidden_field :meta_key_id

    meta_key = meta_datum.object.meta_key
    field_id = "#{sanitize_to_id(meta_datum.object_name)}_value"
    definition = meta_key.meta_key_definitions.for_context(context)
    is_required = (definition.is_required ? true : nil)
    #key_id = meta_datum.object.meta_key_id
    object_id = meta_datum.object.object_id

      case meta_key.meta_datum_object_type
        # TODO set String for 'subject' key, TODO multiple fields for array 
        #       when "String"
        #          h += text_area_tag "media_entry[meta_data_attributes][0][value]", meta_datum.object.to_s
        when "MetaDatumMetaCountry" # FIXME this doesn't exist yet!
          h += widget_meta_countries(meta_datum, meta_key)
    
        when "MetaDatumKeywords"
          h += widget_meta_terms_multiselect(meta_datum, meta_key)
          h += link_to icon_tag("button_add_keyword"), keywords_media_entries_path, :class => "dialog_link", :style => "margin-top: .5em;"

        when "MetaDatumMetaTerms"
          meta_terms = meta_key.meta_terms
          ui = (definition.length_max and definition.length_max == 1 ? :radio_button : :check_box )
          h += widget_meta_terms(meta_datum, meta_key, meta_terms, ui)

        when "MetaDatumPeople"
          h += widget_meta_terms_multiselect(meta_datum, meta_key)
          h += link_to icon_tag("button_add_person"), new_person_path, :class => "dialog_link", :style => "margin-top: .5em;"
          
        when "MetaDatumDate"
          meta_datum.object.value ||= "" # OPTIMIZE
          at = from = to = at_time = ""
          selected_option = "freetext"

          splitted_value = meta_datum.object.value.split(' - ')
          begin
            case splitted_value.size
              when 2
                from = splitted_value.first
                to = splitted_value.last
                selected_option = "from-to" if Date.parse(from) and Date.parse(to)
              when 1
                at = splitted_value.first
                selected_option = "at" if Date.parse(at)
            end
          rescue
            # let's display the freetext
          end

          h += select_tag "dateSelect", options_for_select([["am", "at"], ["von - bis", "from-to"], ["Freie Eingabe", "freetext"]], selected_option)
          
          h += content_tag :span, :class => "dates" do
            a = content_tag :span, :rel => "at" do
              b = text_field_tag "datepicker_at_#{object_id}", at, :class => "datepicker", :placeholder => "TT.MM.JJJJ"
              b += text_field_tag "at_#{object_id}_time", at_time, :class => "time", :placeholder => "HH:MM:SS +HH:MM" unless at_time.blank?
              b
            end
            a += content_tag :span, :rel => "from-to" do
              b = text_field_tag "datepicker_from_#{object_id}", from, :class => "datepicker", :placeholder => "TT.MM.JJJJ"
              b += " - "
              b += text_field_tag "datepicker_to_#{object_id}", to, :class => "datepicker", :placeholder => "TT.MM.JJJJ"
            end
            a += content_tag :span, :rel => "freetext" do
              meta_datum.object.value = meta_datum.object.to_s
              meta_datum.text_field :value, :placeholder => "Wird als Freitext gespeichert."
            end
          end

          @js_1 ||= false
          unless @js_1
            @js_1 = true
            locale = "de-CH"
            #h += javascript_include_tag "i18n/jquery.ui.datepicker-#{locale}"
            h += javascript_tag do
              begin
              <<-HERECODE
                $(document).ready(function(){
                  $("[name='dateSelect']").change(function(){
                    var selected_value = $(this).val();
                    $(this).next(".dates").find("span").hide();
                    var to_show = $(this).next(".dates").find("span[rel='"+selected_value+"']");
                    to_show.show();
                    if(selected_value != "freetext") to_show.find("input:first").trigger("change");
                  }).trigger("change");
                  
                  $(".datepicker").datepicker(
                    $.extend({
                      showOn: "button",
                      buttonImage: "/assets/icons/calendar.png",
                      buttonImageOnly: true,
                      changeMonth: true,
                      changeYear: true,
                      onClose: function(dateText, inst) {
                        $(inst.input.context).trigger("blur");
                      }
                    }, $.datepicker.regional["#{locale}"])
                  );
                                    
                  $(".dates input.datepicker").bind("change", function() {
                    var source = $(this);
                    if(source.is(":visible") && source.val() != source.attr("placeholder")){
                      var v = source.siblings(".datepicker").andSelf().map(function() {
                        var t = $(this).nextAll(".time").first();
                        var r = this.value;
                        if(t.length) r = r + " " + t.val(); 
                        return r;
                      }).get().join(' - ');
                      source.closest(".dates").find("[rel='freetext'] input").val(v);
                    }
                  }).trigger("change");
                  
                  $(".time").bind("change", function() {
                    $(this).prevAll(".datepicker").first().trigger("change");
                  });
                });
              HERECODE
              end.html_safe
            end
          end

        when "MetaDepartment"
          h += widget_meta_terms_multiselect(meta_datum, meta_key)

        when "Copyright"
          #old# h += meta_datum.hidden_field :value, :class => "copyright_value"
          h += hidden_field_tag "#{meta_datum.object_name}[value]", meta_datum.object.value.try(:first), :class => "copyright_value"

          @copyright_all ||= Copyright.all # OPTIMIZE
          @copyright_roots ||= Copyright.roots
          value = meta_datum.object.deserialized_value.try(:first) # OPTIMIZE
          selected = @copyright_roots.detect{|s| (value and s.is_or_is_ancestor_of?(value)) }.try(:id)
          h += select_tag "options_root", options_from_collection_for_select(@copyright_roots, :id, :to_s, selected), :class => "options_root" 

          @copyright_roots.each do |s|
            next if s.leaf?
            grouped_options = s.children.collect do |t|
                                  if t.leaf?
                                    [nil, [[t.label, t.id]]]
                                  else
                                    [t.label, t.children.collect {|c| [c.label, c.id] }]
                                  end
                              end
            is_selected = (value and s.is_or_is_ancestor_of?(value))
            h += select_tag "options_#{s.id}", grouped_options_for_select(grouped_options, value.try(:id)), :class => "nested_options options_#{s.id}", :style => (is_selected ? nil : "display: none;")
          end

          @js_2 ||= false
          h += javascript_tag do
            @js_2 = true
            begin
            <<-HERECODE
              $(document).ready(function(){
                var copyrights = {};
                var custom_copyright_id;
                $.each(#{@copyright_all.to_json}, function(i,item){
                  copyrights[item.id] = item;
                  if(item.is_custom) custom_copyright_id = item.id; 
                });
                
                $("select.nested_options, select.options_root").change(function(event){
                  selected = copyrights[$(this).val()];
                  block = $(this).closest(".meta_data_block");
                  block.find(".copyright_value").val(selected.id);
                  if(!selected.is_custom){
                    block.find("[data-meta_key='copyright_usage'] textarea").val(selected.usage);
                    block.find("[data-meta_key='copyright_url'] textarea").val(selected.url);
                  }
                });
              
                $("select.options_root").change(function(event){
                  block = $(this).closest(".meta_data_block");
                  block.find(".nested_options").hide();
                  block.find(".options_" + selected.id).show().change();

                  usage = block.find("[data-meta_key='copyright_usage']");
                  if(selected.usage == null){
                    usage.hide();
                  }else{
                    usage.show();
                  }
                  url = block.find("[data-meta_key='copyright_url']");
                  if(selected.url == null){
                    url.hide();
                  }else{
                    url.show();
                  }
                });
                
                $("[data-meta_key='copyright_usage'], [data-meta_key='copyright_url']").change(function(event){
                  block = $(this).closest(".meta_data_block");
                  block.find("select.options_root").val(custom_copyright_id).trigger('change');
                });

                //temp//doesn't work with generic nested meta_data// $("select.nested_options:visible, select.options_root").trigger('change');
              });
            HERECODE
            end.html_safe
          end unless @js_2

        when "MetaDatumString", nil
          if definition.length_max and definition.length_max <= 255
            #tmp# h += meta_datum.text_field :value, :class => "value", :"data-required" => is_required
            h += text_field_tag "#{meta_datum.object_name}[value]", meta_datum.object.to_s, :class => "value", :"data-required" => is_required
            h += content_tag :span, :class => "with_actions" do
                  link_to _("Übertragen auf andere Medien"), "#", :class => "hint"
                 end if with_actions # TODO see _bulk_edit
          else
            #tmp# h += meta_datum.text_area :value, :"data-required" => is_required #, :rows => 2
            h += text_area_tag "#{meta_datum.object_name}[value]", meta_datum.object.to_s, :"data-required" => is_required, :rows => 2
          end

      end

    @js_4 ||= false
    h += javascript_tag do
      @js_4 = true
      begin
      <<-HERECODE
        $(document).ready(function(){
            $("##{field_id}").focus();
        });
      HERECODE
      end.html_safe
    end if autofocus and !@js_4

    h
  end

  def description_toggler(definition)
    d = definition.description.try(:to_s)
    unless d.blank?
      content_tag :span, "?", :class => "description_toggler", :title => d #old# auto_link(d, :all, :target => "_blank")
    end
  end

end
