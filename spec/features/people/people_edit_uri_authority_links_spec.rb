require_relative './_shared'

feature 'People' do
  given(:user) { User.find_by(login: 'normin') }
  given(:person) { user.person }
  given(:another_person) { create :person }
  given(:new_values) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      pseudonym: Faker::Name.title,
      description: Faker::Lorem.paragraph,
      external_uris: 2.times.map { Faker::Internet.url }
    }
  end

  feature 'URIAuthorityControl' do
    background do
      sign_in_as user.login

      visit edit_person_path(person)
    end

    EXAMPLES = [
      { input: 'https://example.com', output: nil },

      { input: 'https://another.example.com/viaf/75121530', output: nil },

      {
        input: 'https://d-nb.info/gnd/118529579',
        output: {
          kind: 'GND',
          label: '118529579',
          provider: {
            label: 'GND',
            name: 'Gemeinsame Normdatei',
            url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html'
          }
        }
      },

      {
        input: 'https://lccn.loc.gov/no97021030',
        output: {
          kind: 'LCCN',
          label: 'no97021030',
          provider: {
            label: 'LCCN',
            name: 'Library of Congress Control Number',
            url: 'https://lccn.loc.gov/lccnperm-faq.html'
          }
        }
      },
      {
        input: 'https://id.loc.gov/authorities/names/n79022889',
        output: {
          kind: 'LCCN',
          label: 'n79022889',
          provider: {
            label: 'LCCN',
            name: 'Library of Congress Control Number',
            url: 'https://lccn.loc.gov/lccnperm-faq.html'
          }
        }
      },

      {
        input: 'https://viaf.org/viaf/75121530',
        output: {
          kind: 'VIAF',
          label: '75121530',
          provider: {
            label: 'VIAF',
            name: 'Virtual International Authority File',
            url: 'https://viaf.org'
          }
        }
      },

      {
        input: 'http://www.wikidata.org/entity/Q42',
        output: {
          kind: 'WIKIDATA',
          label: 'Q42',
          provider: {
            label: 'Wikidata',
            name: 'Wikidata Entity URI',
            url: 'https://www.wikidata.org'
          }
        }
      },

      {
        input: 'https://orcid.org/0000-0002-1825-0097',
        output: {
          kind: 'ORCID',
          label: '0000-0002-1825-0097',
          provider: {
            label: 'ORCID iD',
            name: 'Open Researcher and Contributor ID',
            url: 'https://www.orcid.org'
          }
        }
      },

      {
        input: 'https://www.imdb.com/name/nm0251868/',
        output: {
          kind: 'IMDB',
          label: 'nm0251868',
          provider: {
            label: 'IMDb ID',
            name: 'Internet Movie Database identifier',
            url: 'https://www.imdb.com/'
          }
        }
      },

      {
        input: 'https://researcherid.com/rid/K-8011-2013',
        output: {
          kind: 'ResearcherID',
          label: 'K-8011-2013',
          provider: {
            label: 'ResearcherID',
            name: 'Web of Science ResearcherID',
            url: 'https://www.researcherid.com'
          }
        }
      },

      {
        input: 'https://www.researcherid.com/rid/K-8011-2013',
        output: {
          kind: 'ResearcherID',
          label: 'K-8011-2013',
          provider: {
            label: 'ResearcherID',
            name: 'Web of Science ResearcherID',
            url: 'https://www.researcherid.com'
          }
        }
      }
    ].freeze

    EXAMPLES.each do |item|
      scenario "detects correct data for URI: <#{item[:input]}>" do
        click_button I18n.t(:person_edit_add_uri_btn)
        fill_in 'person[pseudonym]', with: Faker::Name.title
        fill_in 'person[external_uris][]', with: item[:input]
        submit_form

        expect(page).to have_current_path(person_path(person))

        if item[:output].nil?
          li_element = find('li', text: item[:input])
          expect(li_element['data-authority-control']).to be_nil
        else
          li_element = find('li[data-authority-control]')
          expect(JSON.parse(li_element['data-authority-control']))
            .to eq(item[:output].deep_stringify_keys)
        end
      end
    end
  end
end
