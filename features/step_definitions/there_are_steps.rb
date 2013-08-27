# -*- encoding : utf-8 -*-
 
 Then /^There are "(.*?)" user-permissions added for me to the resource$/ do |permission|
  permissions = \
    @resource.userpermissions.where(user_id: @me).first  \
    || @resource.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end

Then /^There are "(.*?)" group\-permissions added for me to the resource$/ do |permission|  
  group = Group.joins(:users).where("groups_users.user_id = ?", @me.id).first || (FactoryGirl.create :group)
  group.users << @me unless group.users.include? @me
  grouppermissions = Grouppermission.where(media_resource_id: @resource.id).where(group_id: group.id).first || (Grouppermission.create media_resource_id: @resource.id, group_id: group.id)
  grouppermissions.update_attributes permission => true
end

Then /^There are "(.*?)" user\-permissions added for me to the set$/ do |permission|
  permissions = \
    @set.userpermissions.where(user_id: @me).first  \
    || @set.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end

Then /^There are no persisted visualizations$/ do
  Visualization.delete_all
end

Then /^there are "(.*?)" new media_entries$/ do |num|
  @new_media_entries = MediaEntry.all - @previous_media_entries
  expect(@new_media_entries.size).to eq num.to_i
end

Then /^there are "(.*?)" new zencoder_jobs/ do |num|
  @new_zencoder_jobs = ZencoderJob.all - @previous_zencoder_jobs
  expect(@new_zencoder_jobs.size).to eq num.to_i
end




