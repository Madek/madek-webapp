require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Dashboard' do

  describe 'Beta: Activity Stream' do
    background do
      # prepare data!
      now = DateTime.current
      @user = create(:user, created_at: now - 3.days)

      # start using madek:
      now -= 12.hours

      # upload 5 entries
      @uploads = 5.times.map.with_index do |i|
        upload_entry(created_at: now + (i * 5).seconds)
      end

      now += 3.hours

      # edit and publish 3 of them
      @entries = @uploads.first(3)
      @drafts = @uploads - @entries
      @entries.each.with_index do |entry, i|
        ordinals = %i(erster zweiter dritter vierter fünfter)
        edit_and_publish_entry(
          entry,
          created_at: now + (i * 5).seconds,
          meta_data: {
            'madek_core:title': "Mein #{ordinals[i]} Eintrag",
            'madek_core:description': Faker::Lorem.sentence
          })
      end

      now += 5.minutes

      # make 3 sets
      @sets = 3.times.map.with_index do |i|
        ordinals = %i(erstes zweites drittes viertes fünftes)
        create_set(
          title: "Mein #{ordinals[i]} Set", created_at: now + i.seconds)
      end

      now += 4.hours

      # edit first 2 of the sets,
      # then almost immediately edit an entry (like from another tab)
      @sets.first(2).each do |set|
        edit_set(set, created_at: now, meta_data: {
                   'madek_core:description': Faker::Lorem.sentence
                 })
      end
      edit_and_publish_entry(
        @entries.last, created_at: now + 5.seconds, meta_data: {
          'madek_core:title': 'Mein Kunstwerk'
        })

      # look it at it some more
      now += 23.minutes

      # edit last 1 of the sets
      edit_set(
        @sets.last, created_at: now, meta_data: {
          'madek_core:title': 'Mein Portfolio'
        })

      # TODO: multiple edits in single edit ("X Bearbeitungen")
      # TODO: multiple edits in grouped edit ("X Bearbeitungen")
      # TODO: other users share something with @user (all cases)
      # @uploads.each(&:reload)
      # @sets.each(&:reload)

      @expected_ui_content = [
        { icon: 'icon icon-pen',
          content: {
            summary: 'Sie haben das Set Mein Portfolio bearbeitet.' }
        },
        { icon: 'icon icon-pen',
          content: {
            summary: 'Sie haben den Eintrag Mein Kunstwerk bearbeitet.' }
        },
        { icon: 'icon icon-pen',
          content:           {
            summary: 'Sie haben 2 Sets bearbeitet.',
            details: @sets.first(2).reverse.map do |e|
              { text: e.title, href: collection_path(e) }
            end }
        },
        { icon: 'icon icon-plus',
          content: {
            summary: 'Sie haben 3 Sets erstellt.',
            details: @sets.reverse.map do |e|
              { text: e.title, href: collection_path(e) }
            end }
        },
        { icon: 'icon icon-pen',
          content: {
            summary: 'Sie haben 3 Einträge bearbeitet.',
            details: @entries.reverse.map do |e|
              { text: e.title, href: media_entry_path(e) }
            end }
        },
        { icon: 'icon icon-plus',
          content: {
            summary: "Sie haben 5 Einträge erstellt.",
            details: @uploads.reverse.map do |e|
              { text: e.title || e.media_file.filename,
                href: media_entry_path(e) }

            end
          }
        }
      ]
    end

    it 'renders correctly', browser: false do
      visit my_dashboard_section_path(:activity_stream)
      sign_in_as @user
      expect(page.status_code).to eq 200
      ui_content = get_activity_stream_ui_content(page)
      expect(ui_content).to eq @expected_ui_content
    end

    it 'takes screenshot for docs' do
      visit my_dashboard_section_path(:activity_stream)
      sign_in_as @user
      take_screenshot
    end
  end

end

private

def upload_entry(created_at:)
  create(
    :media_entry_with_image_media_file,
    created_at: created_at, is_published: false,
    creator: @user, responsible_user: @user)
end

def edit_and_publish_entry(entry, meta_data:, created_at:)
  meta_data.map do |k, v|
    _set_meta_datum(entry, meta_key_id: k, string: v)
  end
  create(:edit_session, media_entry: entry, user: @user, created_at: created_at)
  unless entry.is_published
    entry.update_attributes!(is_published: true, updated_at: created_at)
  end
  entry.reload
end

def create_set(title:, created_at:)
  c = create(
    :collection, created_at: created_at,
                 creator: @user, responsible_user: @user)
  create(
    :meta_datum_text, meta_key_id: 'madek_core:title', string: title,
                      collection: c, created_by: @user)
  c.reload
  c
end

def edit_set(set, meta_data:, created_at:)
  meta_data.map do |k, v|
    _set_meta_datum(set, meta_key_id: k, string: v)
  end
  create(:edit_session, collection: set, user: @user, created_at: created_at)
  set.reload
end

def _set_meta_datum(res, meta_key_id:, string:)
  existing_md = MetaDatum.find_by(
    :meta_key_id => meta_key_id,
    res.class.name.singularize.underscore => res
  )
  if existing_md.present?
    existing_md.update_attributes!(string: string)
    existing_md.reload
  else
    md = create(
      :meta_datum_text,
      :meta_key_id => meta_key_id, :string => string,
      :created_by => @user, res.class.name.singularize.underscore => res)
    md.reload
  end
end

def get_activity_stream_ui_content(page)
  page.within('[data-react-class="UI.Views.My.ActivityStream"]') do
    all('.ui-activity-stream > .event').map do |event|
      within(event) do
        content = first('.content') # we only want first-*level* child!
        details = all('ul.extra')[0]
        {
          icon: find('.label .icon')[:class],
          content: within(content) do
            summary = first('.summary') # we only want first-*level* child!
            {
              summary: summary.text,
              details: details && details.all('li').map do |li|
                a = li.find('a')
                { text: a.text, href: url_path(a[:href]) }
              end
            }.compact
          end
        }
      end
    end
  end
end

def url_path(url)
  u = URI.parse(url)
  u.path + (u.query || {}).to_query
end
