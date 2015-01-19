RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_provides_scope, 'it provides scope'
end

RSpec.shared_examples 'favored by user' do

  before :example do
    @user = FactoryGirl.create(:user)
    2.times do
      @user.send("favorite_#{described_class.table_name}") << \
        FactoryGirl.create(described_class.model_name.singular)
    end
  end

  it 'favored by user scope' do
    set1 = \
      Set.new \
        described_class.favored_by(@user)
    set2 = \
      Set.new \
        @user.send("favorite_#{described_class.table_name}")

    expect(set1).to be == set2
  end

end
