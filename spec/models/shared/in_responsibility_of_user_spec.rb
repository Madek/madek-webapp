RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_provides_scope, 'it provides scope'
end

RSpec.shared_examples 'in responsibility of user' do

  before :example do
    @user = FactoryGirl.create(:user)
    2.times do
      @user.send(described_class.table_name) << \
        FactoryGirl.create(described_class.model_name.singular)
    end
  end

  it 'in responsibility by user scope' do
    set1 = \
      Set.new \
        described_class.in_responsibility_of(@user)
    set2 = \
      Set.new \
        @user.send(described_class.table_name)

    expect(set1).to be == set2
  end

end
