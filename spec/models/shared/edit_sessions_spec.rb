RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_has, 'has'
end

RSpec.shared_examples 'edit sessions' do

  it 'has editors' do

    resource = FactoryGirl.create resource_type

    2.times do
      edit_session = FactoryGirl.build(:edit_session)
      edit_session.send("#{resource_type}=", resource)
      edit_session.save
    end

    users_set = Set.new EditSession.where(media_entry_id: resource.id).map(&:user)

    expect(Set.new resource.editors).to eq users_set

  end

end
