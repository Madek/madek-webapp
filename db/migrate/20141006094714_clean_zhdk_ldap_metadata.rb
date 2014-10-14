class CleanZhdkLdapMetadata < ActiveRecord::Migration
  def change
    reversible do |dir| 
      dir.up do 
        execute %[

          DELETE FROM meta_data_institutional_groups
          USING groups
          WHERE groups.id = meta_data_institutional_groups.institutional_group_id
          AND ( institutional_group_name !~* '\.alle'
            OR institutional_group_name ~* '^dozierende' 
            OR institutional_group_name ~* '^mittelbau'
            OR institutional_group_name ~* '^personal'
            OR institutional_group_name ~* '^studirende'
            OR institutional_group_name ~* '^verteilerliste'
            ) 
        ]
      end
    end
  end
end
