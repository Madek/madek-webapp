require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'User API-Tokens' do

  let(:user) { create(:user) }

  it 'is displayed correctly' do
    tokens = 5.times.map { create(:api_token, user: user) }
    data_table = tokens.map do |t|
      [
        t.token_part,
        t.description,
        'in einem Jahr',
        'Lesen: Ja, Schreiben: Nein',
        'icon: fa fa-ban'
      ]
    end

    sign_in_as user
    visit my_dashboard_section_path(:tokens)

    expect(displayed_ui).to eq(data_table)
  end

  example 'create token from list and get secret (32 characters)' do
    description = Faker::Hipster.sentence
    sign_in_as user

    visit my_dashboard_section_path(:tokens)
    click_on 'Neuen Token erstellen'

    fill_in('api_token[description]', with: description)
    expect { submit_form }.to change { ApiToken.count }.by 1

    within('[data-react-class="UI.Views.My.TokenCreatedPage"]') do
      token = ApiToken.last
      expect(page).to have_content token.description

      secret = find('samp.code').text
      expect(secret.length).to be_between(31, 32)
    end
  end

  context 'create token with external application flow' do

    example 'works, giving description and callback_url' do
      description = Faker::Hacker.say_something_smart
      app_url = 'https://madek-app.example.com/postauth'
      sign_in_as user

      visit my_new_api_token_path(description: description, callback_url: app_url)

      within('form[name="api_token"]') do
        info = find('.ui-alert.confirmation')
        description_field = find('textarea[name="api_token[description]"]')
        expect(description_field.text).to eq description
        expect(info.text).to have_content app_url
        expect(info.text).to have_content I18n.t(:api_tokens_callback_description)

        submit_form
      end

      within('.app-body') do
        callback_link = find('.primary-button')[:href]
        url = URI.parse(callback_link)
        token = Rack::Utils.parse_query(url.query)['madek_api_token']
        token_callback_link = app_url + '?' + { madek_api_token: token }.to_query
        shown_token = find('samp.code').text

        expect(token.length).to be_between(31, 32)
        expect(callback_link).to eq token_callback_link
        expect(shown_token).to eq token
      end
    end

    example 'does not support insecure/http URLs' do
      description = Faker::Hacker.say_something_smart
      app_url = 'http://insecure.example.com/firesheep'

      sign_in_as user
      visit my_new_api_token_path(description: description, callback_url: app_url)
      expect(page).to have_content \
        'Insecure URL `http://insecure.example.com/firesheep`!'
    end

  end

end

private

def displayed_ui
  table = find('.ui-resources-holder table')
  table.all('tr').drop(1).map do |tr|
    fields = tr.all('td')
    btn_icon = fields.last.find('button i')[:class]
    # NOTE: ignore the created timestamp, we cant know the UI text!
    [
      fields[0].text, fields[1].text, fields[3].text,
      fields[4].text, "icon: #{btn_icon}"
    ]
  end
end
