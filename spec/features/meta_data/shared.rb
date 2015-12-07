module Features
  module MetaData
    module Shared

      def visit_edit_page_of_user_first_media_entry
        @media_entry = @current_user.media_entries.reorder(:created_at,:id).first
        visit edit_media_resource_path(@media_entry)
      end

      def assert_page_of_user_first_media_entry
        @media_entry = @current_user.media_entries.reorder(:created_at,:id).first
        expect(current_path).to eq media_entry_path(@media_entry)
      end

      def assert_multi_select_tag text
        expect(page).to have_selector("li.multi-select-tag",text: text)
      end

      def click_on_the_fieldset_icon data_meta_key_name
        find("fieldset[data-meta-key='#{data_meta_key_name}'] a.form-widget-toggle").click
      end

      def delete_all_existing_authors
        all("fieldset[data-meta-key='author'] ul.multi-select-holder li a",visible:true).each{|e| e.click}
      end

      def assert_textarea_within_fieldset_not_empty meta_key
        expect(find("fieldset[data-meta-key='#{meta_key}'] textarea").value.strip).not_to eq ""
      end

      def assert_textarea_within_fieldset_is_empty meta_key
        expect(find("fieldset[data-meta-key='#{meta_key}'] textarea").value.strip).to eq ""
      end

      def edit_multiple_media_entries_using_the_batch
        @collection = Collection.add @current_user.media_entries.map(&:id)
        visit edit_multiple_media_entries_path(:collection_id => @collection[:id])
      end

      def change_and_remember_the_value_of_each_visible_meta_data_field
        @meta_data= []
        all("form fieldset",visible: true).each_with_index do |field_set,i|

          type = field_set[:'data-type']
          meta_key = field_set[:'data-meta-key']

          # this is for logging
          @current_field_set= field_set
          @current_index= i
          @current_type = type
          @current_meta_key = meta_key


          case type

          when 'meta_datum_string'
            @meta_data[i] = HashWithIndifferentAccess.new(
              value: Faker::Lorem.words.join(" "),
              meta_key: meta_key,
              type: type)
            if field_set.all("textarea").size > 0
              field_set.find("textarea").set(@meta_data[i][:value])
            else
              field_set.find("input[type='text']").set(@meta_data[i][:value])
            end

          when 'meta_datum_people'
            # remove all existing
            field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
            @people ||= Person.all
            random_person =  @people[rand @people.size]
            @meta_data[i] = HashWithIndifferentAccess.new(
              value: random_person.to_s,
              meta_key: meta_key,
              type: type)

            autocomplete(field_set.find("input.form-autocomplete-person"), random_person.to_s)
            expect(field_set).to have_selector("a",text: random_person.to_s)
            field_set.find("a",text: random_person.to_s, match: :first).click

          when 'meta_datum_date'
            @meta_data[i] = HashWithIndifferentAccess.new(
              value: Time.at(rand Time.now.tv_nsec).iso8601,
              meta_key: meta_key,
              type: type)
            field_set.find("input", visible: true).set(@meta_data[i][:value])

          when 'meta_datum_keywords'

            field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
            @kws ||= KeywordTerm.joins(:keywords).select("term").uniq.map(&:term).sort
            random_kw = @kws[rand @kws.size]
            @meta_data[i] = HashWithIndifferentAccess.new(
              value: random_kw,
              meta_key: meta_key,
              type: type)

            autocomplete(field_set.find("input", visible: true), random_kw)
            expect(field_set).to have_selector("a",text: random_kw)
            field_set.find("a", text: random_kw, match: :first).click


          when 'meta_datum_meta_terms'
            if field_set['data-is-extensible-list']
              field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
              field_set.find("input",visible: true).click
              page.execute_script %Q{ $("input.ui-autocomplete-input").trigger("change") }
              expect(field_set).to have_selector("ul.ui-autocomplete li a",visible: true)
              targets = field_set.all("ul.ui-autocomplete li a",visible: true)
              targets[rand targets.size].click
              expect(field_set).to have_selector("ul.multi-select-holder li.meta-term")
              @meta_data[i] = HashWithIndifferentAccess.new(
                value: field_set.first("ul.multi-select-holder li.meta-term").text,
                type: type,
                meta_key: meta_key)
            else
              checkboxes = field_set.all("input[type='checkbox']", visible: true)
              checkboxes.each{|c| c.set false}
              checkboxes[rand checkboxes.size].click
              @meta_data[i] = HashWithIndifferentAccess.new(
                value: field_set.all("input[type='checkbox']", visible: true).select(&:checked?).first.find(:xpath,".//..").text,
                meta_key: meta_key,
                type: type)
            end

          when 'meta_datum_institutional_groups'
            field_set.all(".multi-select li a.multi-select-tag-remove").each{|a| a.click}
            field_set.find("input",visible: true).click
            directly_chooseable= field_set.all("ul.ui-autocomplete li:not(.has-navigator) a",visible: true)
            directly_chooseable[rand directly_chooseable.size].click
            @meta_data[i] = HashWithIndifferentAccess.new(
              value: field_set.first("ul.multi-select-holder li.meta-term").text,
              type: type,
              meta_key: meta_key)
          else
            rais "Implement this case"
          end

          Rails.logger.info ["setting metadata filed value", field_set[:'data-meta-key'], @meta_data[i] ]
        end


        def every_meta_data_value_is_visible_on_the_page
          @meta_data_by_context.each do |context_id,meta_data|
            meta_data.each do |md|
              value= md[:value]
              case md[:type]
              when 'meta_datum_institutional_groups'
                expect(page).to have_content stable_part_of_meta_datum_institutional_group(value)
              else
                expect(page).to have_content value
              end
            end
          end
        end

        def stable_part_of_meta_datum_institutional_group group_name
          group_name.match(/^(.*)\(/).captures.first
        end

        def each_meta_data_value_in_each_context_is_equal_to_the_one_set_previously
          all("ul.contexts > li").each do |context|
            context.find("a").click()
            @meta_data = @meta_data_by_context[context[:'data-context-id']]
            each_meta_data_value_is_equal_to_the_one_set_previously
          end
        end

        def each_meta_data_value_is_equal_to_the_one_set_previously
          all("form fieldset",visible: true).each_with_index do |field_set,i|

            type = field_set[:'data-type']
            meta_key = field_set[:'data-meta-key']

            @current_field_set= field_set
            @current_index= i
            @current_type = type
            @current_meta_key = meta_key


            case type
            when 'meta_datum_string'
              if field_set.all("textarea").size > 0
                expect(@meta_data[i][:value]).to eq field_set.find("textarea").value
              else
                expect(@meta_data[i][:value]).to eq field_set.find("input[type='text']").value
              end
            when 'meta_datum_people'
              expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
            when 'meta_datum_date'
              expect(field_set.find("input", visible: true).value).to eq @meta_data[i][:value]
            when 'meta_datum_keywords'
              #expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
              expect(field_set.all("ul.multi-select-holder li",text: @meta_data[i][:value]).size ).to eq 1
            when 'meta_datum_meta_terms'
              if field_set['data-is-extensible-list']
                expect(field_set.first("ul.multi-select-holder li.meta-term").text).to eq  @meta_data[i][:value]
              else
                expect(field_set.all("input[type='checkbox']", visible: true).select(&:checked?).first.find(:xpath,".//..").text).to eq @meta_data[i][:value]
              end
            when 'meta_datum_institutional_groups'
              expect( stable_part_of_meta_datum_institutional_group(field_set.first("ul.multi-select-holder li.meta-term").text)).to \
                eq stable_part_of_meta_datum_institutional_group(@meta_data[i][:value])
            else
              raise "Implement this case"
            end
          end
        end
      end

      def autocomplete(node, text)
        node.click
        node.native.send_keys(text)
      end

    end
  end
end
