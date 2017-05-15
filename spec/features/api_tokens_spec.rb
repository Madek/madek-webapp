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
        'bis in einem Jahr',
        'Zugriff: Lesen: Ja, Schreiben: Nein.',
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

end

private

def displayed_ui
  table = find('.ui-resources-holder table')
  table.all('tr').map do |tr|
    fields = tr.all('td')
    btn_icon = fields.last.find('button i')[:class]
    # NOTE: ignore the created timestamp, we cant know the UI text!
    [
      fields[0].text, fields[1].text, fields[3].text,
      fields[4].text, "icon: #{btn_icon}"
    ]
  end
end
