class RenameLdapNamesInGroupsTable < ActiveRecord::Migration
  def change
    rename_column :groups, :ldap_id, :institutional_group_id
    rename_column :groups, :ldap_name, :institutional_group_name
  end
end
