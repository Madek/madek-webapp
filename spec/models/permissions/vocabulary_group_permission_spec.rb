require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::VocabularyGroupPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :vocabulary_group_permission }
      .not_to raise_error
  end

  context 'Group and Vocabulary ' do

    before :each do
      @group = FactoryGirl.create :group
      @creator = FactoryGirl.create :group
      @vocabulary = FactoryGirl.create :vocabulary
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and group is not the responsible_group) do
        before :each do
          @permission = \
            FactoryGirl.create(:vocabulary_group_permission,
                               view: false,
                               use: false,
                               group: (FactoryGirl.create :group),
                               vocabulary: @vocabulary)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
