object @media_entry
attributes :id, :user_id, :created_at, :updated_at, :media_file_id

node :owner_id do  |me|
  me.user.id
end

