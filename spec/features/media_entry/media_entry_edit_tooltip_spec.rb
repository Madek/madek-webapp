require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Media Entry edit - tooltip' do
  given(:user) { create(:user, password: 'password') }
  given(:media_entry) { create(:media_entry_with_title, responsible_user: user) }

  background do
    sign_in_as user, 'password'
  end

  describe 'Context Key\'s documentation url' do
    given(:valid_url) { Faker::Internet.url('example.com') }
    given(:invalid_url) { 'invalid_url' }
    given(:meta_key) do
      create(:meta_key_text, id: 'media_content:test', labels: { de: 'Test Meta Key' })
    end
    given!(:context_key) do
      create(:context_key,
             context_id: 'media_content',
             meta_key: meta_key,
             labels: { de: 'Test Context Key' })
    end
    given(:params) { {} }

    def visit_context_path(context_id = 'media_content')
      visit edit_meta_data_by_context_media_entry_path(media_entry, context_id, params)
    end

    shared_examples 'tooltip contains the link' do
      scenario 'tooltip contains the link' do
        visit_context_path

        within(find('.form-label', text: context_key.label)) do
          find('.ui-ttip-toggle').hover
        end

        within '.tooltip' do
          expect(page).to have_content(description)
          expect(page).to have_link(I18n.t(:meta_data_meta_key_documentation_url),
                                    href: valid_url)
        end
      end
    end

    shared_examples 'tooltip does not contain any link' do
      scenario 'tooltip does not contain any link' do
        visit_context_path

        within(find('.form-label', text: context_key.label)) do
          find('.ui-ttip-toggle').hover
        end

        within '.tooltip' do
          expect(page).to have_content(description)
          expect(page).not_to have_link
        end
      end
    end

    context 'when description is set' do
      let(:description) { context_key.description }

      context 'when documentation URL is set' do
        context 'on Meta Key and is valid' do
          background do
            meta_key.update(documentation_urls: { de: valid_url })
          end

          include_examples 'tooltip contains the link'
        end

        context 'on Context Key and is valid' do
          background do
            context_key.update(documentation_urls: { de: valid_url })
          end

          include_examples 'tooltip contains the link'
        end

        context 'on Meta Key and is invalid' do
          background do
            meta_key.update(documentation_urls: { de: invalid_url })
          end

          include_examples 'tooltip does not contain any link'
        end

        context 'on Context Key and is invalid' do
          background do
            meta_key.update(documentation_urls: { de: invalid_url })
          end

          include_examples 'tooltip does not contain any link'
        end

        context 'as invalid on Context Key, but Meta Key has a valid url' do
          background do
            meta_key.update(documentation_urls: { de: valid_url })
            context_key.update(documentation_urls: { de: invalid_url })
          end

          include_examples 'tooltip contains the link'
        end
      end

      context 'when documentation URL is unset' do
        include_examples 'tooltip does not contain any link'
      end

      describe 'urls precedence' do
        let(:params) { { lang: :en } }

        background { I18n.locale = :en }

        context 'when Context Key has no url for english locale' do
          let(:german_url) { Faker::Internet.url('example.com', '?lang=de') }
          let(:english_url) { Faker::Internet.url('example.com', '?lang=en') }

          context 'but Meta Key has' do
            let(:valid_url) { english_url }

            background { meta_key.update!(documentation_urls: { en: english_url }) }

            include_examples 'tooltip contains the link'
          end

          context 'but has for default locale' do
            let(:valid_url) { german_url }

            background do
              meta_key.update!(documentation_urls: { de: 'http:://irrelevant_url.en' })
              context_key.update!(documentation_urls: { de: german_url })
            end

            include_examples 'tooltip contains the link'
          end

          context 'but Meta Key has for default locale' do
            let(:valid_url) { german_url }

            background { meta_key.update!(documentation_urls: { de: german_url }) }

            include_examples 'tooltip contains the link'
          end
        end
      end
    end
  end
end
