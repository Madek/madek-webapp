require_relative './_shared'

feature 'People' do
  given(:user) { User.find_by(login: 'normin') }
  given(:person) { user.person }
  given(:another_person) { create :person }
  given(:new_values) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      pseudonym: Faker::Artist.name,
      description: Faker::Lorem.paragraph,
      external_uris: 2.times.map { Faker::Internet.url }
    }
  end

  context 'when user is a person owner' do
    scenario 'Showing edit button' do
      sign_in_as user.login

      within('.ui-header-user') do
        find('.dropdown-toggle').click
        find('.dropdown-menu a', text: I18n.t(:user_menu_my_person)).click
      end

      within('.ui-body-title-actions') do
        expect(page).to have_link(
          I18n.t(:person_show_edit_btn), href: edit_person_path(person)
        )
      end
    end

    scenario 'Editing' do
      sign_in_as user.login

      within('.ui-header-user') do
        find('.dropdown-toggle').click
        find('.dropdown-menu a', text: I18n.t(:user_menu_my_person)).click
      end

      within('.ui-body-title-actions') do
        click_link(I18n.t(:person_show_edit_btn))
      end

      expect(page).to have_current_path(edit_person_path(person))

      # fill_in 'person[first_name]', with: new_values[:first_name]
      # fill_in 'person[last_name]', with: new_values[:last_name]
      fill_in 'person[pseudonym]', with: new_values[:pseudonym]
      fill_in 'person[description]', with: new_values[:description]
      new_values[:external_uris].each { |uri| add_uri(uri) }

      submit_form

      expect(page).to have_current_path(person_path(person))
      expect(page).to have_css('.ui-alert.success')

      expect(page).to have_content(
        person[:first_name] + ' ' + person[:last_name] + ' (' + new_values[:pseudonym] + ')'
      )
      # expect_person_detail(:first_name, new_values)
      # expect_person_detail(:last_name, new_values)
      expect_person_detail(:description, new_values)
      expect(page).to have_content(
        [
          I18n.t(:person_show_external_uris),
          *new_values[:external_uris]
        ].join("\n")
      )
    end

    feature 'Previews of links' do
      background do
        sign_in_as user.login

        visit edit_person_path(person)
      end

      context 'provider: GND' do
        scenario 'Showing decorated preview' do
          add_uri('https://d-nb.info/gnd/118819836')
          expect_preview('GND: 118819836')
        end

        scenario 'Showing just an url' do
          add_uri('https://d-nb.info/gnd/118819836/')
          expect_just_a_link('https://d-nb.info/gnd/118819836/')
        end
      end

      context 'provider: LCCN' do
        scenario 'Showing decorated preview' do
          add_uri('https://lccn.loc.gov/no97021030')
          expect_preview('LCCN: no97021030')

          add_uri('https://id.loc.gov/authorities/names/n79022889')
          expect_preview('LCCN: n79022889')
        end

        scenario 'Showing just an url' do
          add_uri('https://lccn.loc.gov/no97021030x')
          expect_just_a_link('https://lccn.loc.gov/no97021030x')

          add_uri('https://id.loc.gov/authorities/names/n79022889x')
          expect_just_a_link('https://id.loc.gov/authorities/names/n79022889x')
        end
      end

      context 'provider: IMDB' do
        scenario 'Showing decorated preview' do
          add_uri('https://www.imdb.com/name/nm0251868/')
          expect_preview('IMDb ID: nm0251868')
        end

        scenario 'Showing just an url' do
          add_uri('https://www.imdb.com/name/nm0251868')
          expect_just_a_link('https://www.imdb.com/name/nm0251868')
        end
      end

      context 'provider: ORCID' do
        scenario 'Showing decorated preview' do
          add_uri('https://orcid.org/0000-0002-1825-0097')
          expect_preview('ORCID iD: 0000-0002-1825-0097')
        end

        scenario 'Showing just an url' do
          add_uri('https://orcid.org/0000-0002-1825-0097/')
          expect_just_a_link('https://orcid.org/0000-0002-1825-0097/')
        end
      end

      context 'provider: ResearcherID' do
        scenario 'Showing decorated preview' do
          add_uri('https://www.researcherid.com/rid/K-8011-2013')
          expect_preview('ResearcherID: K-8011-2013')
        end

        scenario 'Showing just an url' do
          add_uri('https://www.researcherid.com/rid/K-8011-2013/')
          expect_just_a_link('https://www.researcherid.com/rid/K-8011-2013/')
        end
      end

      context 'provider: VIAF' do
        scenario 'Showing decorated preview' do
          add_uri('https://viaf.org/viaf/75121530')
          expect_preview('VIAF: 75121530')
        end

        scenario 'Showing just an url' do
          add_uri('https://viaf.org/viaf/75121530x')
          expect_just_a_link('https://viaf.org/viaf/75121530x')
        end
      end

      context 'provider: WIKIDATA' do
        scenario 'Showing decorated preview' do
          add_uri('http://www.wikidata.org/entity/Q42')
          expect_preview('Wikidata: Q42')
        end

        scenario 'Showing just an url' do
          add_uri('http://www.wikidata.org/entity/Q42x')
          expect_just_a_link('http://www.wikidata.org/entity/Q42')
        end
      end

      scenario 'Showing just an url for common url' do
        add_uri('http://example.com/')
        expect_just_a_link('http://example.com/')
      end
    end
  end

  context 'when user is not a person owner' do
    scenario 'Not showing edit button' do
      sign_in_as user.login
      # show button for myself (protect against false negative in next check)
      visit person_path(person)
      within('.ui-body-title-actions') do
        expect(page).to have_content(I18n.t(:person_show_edit_btn))
      end
      # dont show button for other person
      visit person_path(another_person)
      expect(page).not_to have_selector('.ui-body-title-actions')
      expect(page).not_to have_content(I18n.t(:person_show_edit_btn))
    end
  end

  feature 'URIAuthorityControl' do
    background do
      sign_in_as user.login

      visit edit_person_path(person)
    end

    PEOPLE_EXAMPLES = [
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

    PEOPLE_EXAMPLES.each do |item|
      scenario "detects correct data for URI: <#{item[:input]}>" do
        click_button I18n.t(:person_edit_add_uri_btn)
        fill_in 'person[pseudonym]', with: Faker::Artist.name
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
