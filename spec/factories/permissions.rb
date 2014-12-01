FactoryGirl.define do


  factory :collection_group_permission, class: Permissions::CollectionGroupPermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    edit_metadata_and_relations {FactoryHelper.rand_bool 1/4.0}

    group {Group.find_random || (FactoryGirl.create :group)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    collection {Collection.find_random || (FactoryGirl.create :collection)}

  end



  factory :media_entry_user_permission, class: Permissions::MediaEntryUserPermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    get_full_size{get_metadata_and_previews and FactoryHelper.rand_bool}
    edit_metadata {FactoryHelper.rand_bool 1/4.0}
    edit_permissions {edit_metadata and FactoryHelper.rand_bool}

    user {User.find_random || (FactoryGirl.create :user)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end


  factory :media_entry_group_permission, class: Permissions::MediaEntryGroupPermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    get_full_size{get_metadata_and_previews and FactoryHelper.rand_bool}
    edit_metadata {FactoryHelper.rand_bool 1/4.0}

    group {Group.find_random || (FactoryGirl.create :group)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end



  factory :media_entry_api_client_permission, class: Permissions::MediaEntryApiClientPermission do

    get_metadata_and_previews {FactoryHelper.rand_bool 1/4.0}
    get_full_size{get_metadata_and_previews and FactoryHelper.rand_bool}

    api_client {ApiClient.find_random || (FactoryGirl.create :api_client)} 
    updator {User.find_random || (FactoryGirl.create :user)}
    media_entry {MediaEntry.find_random || (FactoryGirl.create :media_entry)}

  end



end
