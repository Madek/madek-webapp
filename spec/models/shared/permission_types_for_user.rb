RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_responds_to, 'it responds to'
end

RSpec.shared_examples 'permission_types_for_user' do
  let(:model_name) { described_class.model_name }

  it 'as responsible' do
    user = FactoryGirl.create(:user)
    group1 = FactoryGirl.create(:group)
    group2 = FactoryGirl.create(:group)
    user.groups << group1
    user.groups << group2
    resource = FactoryGirl.create(model_name.singular,
                                  responsible_user: user)

    perm_types = \
      "Permissions::Modules::#{model_name.name}::PERMISSION_TYPES"
        .constantize
    group_perm_types = (perm_types - irrelevant_group_perm_types)

    FactoryGirl.create("#{model_name.singular}_user_permission",
                       Hash[:user, user,
                            model_name.singular, resource,
                            perm_types.sample, true])
    FactoryGirl.create("#{model_name.singular}_group_permission",
                       Hash[:group, group1,
                            model_name.singular, resource,
                            group_perm_types.sample, true])
    FactoryGirl.create("#{model_name.singular}_group_permission",
                       Hash[:group, group2,
                            model_name.singular, resource,
                            group_perm_types.sample, true])

    expect(Set.new(resource.permission_types_for_user(user)))
      .to be == Set.new(perm_types)
  end

  it 'as user and group permission' do
    user = FactoryGirl.create(:user)
    resource = FactoryGirl.create(model_name.singular,
                                  responsible_user: FactoryGirl.create(:user))

    perm_types = \
      "Permissions::Modules::#{model_name.name}::PERMISSION_TYPES"
        .constantize
    perm_attributes = Hash[perm_types.zip(Array.new(perm_types.length, false))]
    user_perm_type = perm_types.sample
    perm_attributes[user_perm_type] = true

    group_perm_types = (perm_types - irrelevant_group_perm_types)

    FactoryGirl.create("#{model_name.singular}_user_permission",
                       Hash[:user, user,
                            model_name.singular, resource]
                        .merge(perm_attributes))

    group_perm_types.each do |group_perm_type|
      group = FactoryGirl.create(:group)
      user.groups << group
      FactoryGirl.create("#{model_name.singular}_group_permission",
                         Hash[:group, group,
                              model_name.singular, resource,
                              group_perm_type, true])
    end

    expect(Set.new(resource.permission_types_for_user(user)))
      .to be == Set.new([user_perm_type, *group_perm_types].uniq)
  end
end
