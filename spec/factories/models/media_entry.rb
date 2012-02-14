
FactoryGirl.define do

  factory :media_entry do
    user {User.find_random || (FactoryGirl.create :user)}
    media_file {FactoryGirl.create :media_file}
  end

end
