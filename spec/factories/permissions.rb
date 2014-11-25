FactoryGirl.define do

  factory :media_entry_userpermission, class: Permissions::MediaEntryUserpermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    get_full_size{get_metadata_and_previews and FactoryHelper.rand_bool}
    edit_metadata {FactoryHelper.rand_bool 1/4.0}
    edit_permissions {edit_metadata and FactoryHelper.rand_bool}

    user {User.find_random || (FactoryGirl.create :user)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end


  factory :media_entry_grouppermission, class: Permissions::MediaEntryGrouppermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    get_full_size{get_metadata_and_previews and FactoryHelper.rand_bool}
    edit_metadata {FactoryHelper.rand_bool 1/4.0}

    group {Group.find_random || (FactoryGirl.create :group)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end





end
