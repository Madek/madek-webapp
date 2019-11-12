module MetaDatumInputsHelper
  private

  def configure_as_only_input(context_key)
    # ensure at least 2 tabs:
    other_context = FactoryGirl.create(:context)
    FactoryGirl.create(:context_key, context: other_context, meta_key_id: 'madek_core:title')
    AppSetting.first.update_attributes!(
      contexts_for_entry_edit: [context_key.context_id, other_context.id],
      context_for_entry_summary: context_key.context_id
    )
  end

  def edit_in_meta_data_form(key = @context_key, save_form = false, &block)
    throw ArgumentError unless block_given?
    visit edit_meta_data_by_context_media_entry_path(@media_entry)
    sign_in_as @user.login
    tabs = find('.app-body-ui-container .ui-tabs.large').all('.ui-tabs-item')
    within('form[name="resource_meta_data"]') do
      within(form_group(key), &block)
      if save_form
        # change tab before saving to make sure that really works
        tabs.last(2).first.click
        submit_form
      end
    end
  end

  def edit_in_meta_data_form_and_save(key = @context_key, &block)
    edit_in_meta_data_form(key, true, &block)
  end

  def form_group(key = @context_key)
    find('.ui-form-group', text: key.label)
  end

  def expect_meta_datum_on_detail_view(str, shown: true, key: @context_key)
    wait_until { current_path == media_entry_path(@media_entry) }
    within('.ui-media-overview-metadata') do
      expect(page.has_css?('.media-data-title', text: key.label)).to(
        be(shown),
        "expected label '#{key.label}' to #{shown ? '' : 'NOT'} be shown"
      )

      actual = all('.media-data-content').try(:first).try(:text)
      expect(page.has_css?('.media-data-content', text: str)).to(
        be(shown),
        "expected: '#{str}' to #{shown ? '' : 'NOT'} be shown, got: #{actual}"
      )
    end
  end
end
