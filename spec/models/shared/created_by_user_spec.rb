RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_provides_scope, 'it provides scope'
end

RSpec.shared_examples 'created by user' do

  before :example do
    @user = FactoryGirl.create(:user)
    2.times do
      FactoryGirl.create(described_class.model_name.singular,
                         creator: @user)
    end
  end

  it 'created by user scope' do
    set1 = \
      Set.new \
        described_class.created_by(@user)
    set2 = \
      Set.new \
        described_class.where(creator: @user)

    expect(set1).to be == set2
  end

end
