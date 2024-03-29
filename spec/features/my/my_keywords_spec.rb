require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Keyword; in User Dashboard ("My Keywords")',
        browser: :firefox do

  let(:user) { User.find_by(login: 'normin') }

  background do
    sign_in_as user.login
  end

  it '' do
    keyword_1 = FactoryBot.create(:keyword,
                                   meta_key_id: 'madek_core:keywords')
    keyword_1_usage_count = 20
    keyword_1_usage_count.times do
      FactoryBot.create(:meta_datum_keyword,
                         meta_datum: \
                           FactoryBot.create(:meta_datum_keywords,
                                              meta_key_id: 'madek_core:keywords'),
                         keyword: keyword_1,
                         created_by: user)
    end

    keyword_2 = FactoryBot.create(:keyword,
                                   meta_key_id: 'madek_core:keywords')
    keyword_2_usage_count = 19
    keyword_2_usage_count.times do
      FactoryBot.create(:meta_datum_keyword,
                         meta_datum: \
                           FactoryBot.create(:meta_datum_keywords,
                                              meta_key_id: 'madek_core:keywords'),
                         keyword: keyword_2,
                         created_by: user)
    end

    keyword_3 = FactoryBot.create(:keyword,
                                   meta_key_id: 'madek_core:keywords')
    keyword_3_usage_count = 18
    keyword_3_usage_count.times do
      FactoryBot.create(:meta_datum_keyword,
                         meta_datum: \
                           FactoryBot.create(:meta_datum_keywords,
                                              meta_key_id: 'madek_core:keywords'),
                         keyword: keyword_3,
                         created_by: user)
    end

    visit '/my/used_keywords'
    expect(
      all('.ui-tag-cloud-item').take(3).map(&:text)
    ).to be == ["#{keyword_1.term} #{keyword_1_usage_count}",
                "#{keyword_2.term} #{keyword_2_usage_count}",
                "#{keyword_3.term} #{keyword_3_usage_count}"]

    visit '/my'
    within '#used_keywords' do
      expect(
        all('.ui-tag-cloud-item').take(3).map(&:text)
      ).to be == ["#{keyword_1.term} #{keyword_1_usage_count}",
                  "#{keyword_2.term} #{keyword_2_usage_count}",
                  "#{keyword_3.term} #{keyword_3_usage_count}"]
    end
  end

end
