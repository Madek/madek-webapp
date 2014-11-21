FactoryGirl.define do

  factory :media_entry_userpermission, class: Permissions::MediaEntryUserpermission do

    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}

    user {User.find_random || (FactoryGirl.create :user)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end

end
