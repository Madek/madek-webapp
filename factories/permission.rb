FactoryGirl.define do

  factory :permission do
    subject {FactoryHelper.rand_bool ? User.find_random : Group.find_random }
    media_resource { MediaResource.find_random }
    after(:build) {|perm| 
      permissions = {:view => FactoryHelper.rand_bool, :edit => FactoryHelper.rand_bool, :manage => FactoryHelper.rand_bool, :download => FactoryHelper.rand_bool}
      perm.set_actions permissions 
    }
  end

  factory :userpermission do
    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}
    user {User.find_random || (FactoryGirl.create :user)} 

    media_resource do 
      MediaResource.find_random || 
        begin
          if FactoryHelper.rand_bool 1.0/3
            FactoryGirl.create :media_set
          else
            FactoryGirl.create :media_entry
          end
        end
    end
  end

  factory :grouppermission do
    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}

    group {Group.find_random || (FactoryGirl.create :group)}

    media_resource do 
      if FactoryHelper.rand_bool 1.0/3
        FactoryGirl.create :media_set
      else
        FactoryGirl.create :media_entry
      end
    end
  end
  
end
