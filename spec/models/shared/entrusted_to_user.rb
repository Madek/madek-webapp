RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_provides_scope, 'it provides scope'
end

RSpec.shared_examples 'entrusted to user' do

  before :example do
    @user = FactoryGirl.create :user
    group1 = FactoryGirl.create(:group)
    group2 = FactoryGirl.create(:group)
    @user.groups << group1
    @user.groups << group2

    model_name = described_class.model_name.singular

    resource = FactoryGirl.create(model_name.to_sym)
    arg_hash = { get_metadata_and_previews: true }

    FactoryGirl.create "#{model_name}_user_permission".to_sym,
                       arg_hash.merge(Hash['user',
                                           @user,
                                           model_name,
                                           FactoryGirl.create(model_name.to_sym)])
    FactoryGirl.create "#{model_name}_user_permission".to_sym,
                       arg_hash.merge(Hash['user',
                                           @user,
                                           model_name,
                                           resource])
    FactoryGirl.create "#{model_name}_group_permission".to_sym,
                       arg_hash.merge(Hash['group',
                                           group1,
                                           model_name,
                                           resource])
    FactoryGirl.create "#{model_name}_group_permission".to_sym,
                       arg_hash.merge(Hash['group',
                                           group2,
                                           model_name,
                                           FactoryGirl.create(model_name.to_sym)])
  end

  it 'union of entrusted_to_user_directly and entrusted_to_user_through_groups' do
    entrusted_to_user_directly = \
      described_class.by_user_directly(@user,
                                       described_class::VIEW_PERMISSION_NAME)
    entrusted_to_user_through_groups = \
      described_class.by_user_through_groups(@user,
                                             described_class::VIEW_PERMISSION_NAME)
    result_union = \
      (entrusted_to_user_directly + entrusted_to_user_through_groups).uniq

    expect(result_union.count)
      .to be == described_class.entrusted_to_user(@user).count
    expect(result_union.count).to be 3
  end

end
