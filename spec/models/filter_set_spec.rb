require 'spec_helper'
require Rails.root.join 'spec', 'models', 'shared', 'favoritable_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'edit_sessions_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'entrusted_to_user_spec.rb'
require Rails.root.join 'spec', 'models', 'shared', 'validates_spec.rb'

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

  it_provides_scope 'entrusted to user'

end
