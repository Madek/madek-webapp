object @media_set
attributes :id, :user_id, :created_at, :updated_at
node :owner_id do  |me|
  me.user.id
end

child @media_entries do
  extends "media_entries/show"
end
