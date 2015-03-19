require 'spec_helper'

[
  'created_by_user.rb',
  'edit_sessions.rb',
  'entrusted_to_user.rb',
  'favored_by_user.rb',
  'favoritable.rb',
  'in_responsibility_of_user.rb',
  'meta_data.rb',
  'permission_types_for_user.rb',
  'validates.rb'
]
  .each do |file|
  require Rails.root.join 'spec', 'models', 'shared', file
end

##########################################################

describe FilterSet do

  describe 'Creation' do

    it 'should be producible by a factory' do
      expect { FactoryGirl.create :filter_set }.not_to raise_error
    end

  end

  describe 'Update' do

    it_validates 'presence of', :responsible_user_id
    it_validates 'presence of', :creator_id

  end

  context 'an existing filter set' do

    it_has 'edit sessions' do
      let(:resource_type) { :filter_set }
    end

    it_behaves_like 'a favoritable' do
      let(:resource) { FactoryGirl.create :filter_set }
    end
  end

  it_provides_scope 'created by user'
  it_provides_scope 'entrusted to user'
  it_provides_scope 'favored by user'
  it_provides_scope 'in responsibility of user'

  context 'reader methods for meta_data' do

    it_provides_reader_method_for 'title'
    it_provides_reader_method_for 'description'
    it_provides_reader_method_for 'keywords'

  end

  it_responds_to 'permission_types_for_user' do
    let(:irrelevant_group_perm_types) \
      { [:edit_metadata_and_filter, :edit_permissions] }
  end
end
