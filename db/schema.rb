# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110128143744) do

  create_table "copyrights", :force => true do |t|
    t.boolean "is_default", :default => false
    t.boolean "is_custom",  :default => false
    t.string  "label"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "usage"
    t.string  "url"
  end

  add_index "copyrights", ["is_custom"], :name => "index_copyrights_on_is_custom"
  add_index "copyrights", ["is_default"], :name => "index_copyrights_on_is_default"
  add_index "copyrights", ["label"], :name => "index_copyrights_on_label", :unique => true
  add_index "copyrights", ["lft", "rgt"], :name => "index_copyrights_on_lft_and_rgt"
  add_index "copyrights", ["parent_id"], :name => "index_copyrights_on_parent_id"

  create_table "edit_sessions", :force => true do |t|
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edit_sessions", ["resource_id", "resource_type", "created_at"], :name => "index_on_resource_and_created_at"
  add_index "edit_sessions", ["user_id"], :name => "index_edit_sessions_on_user_id"

  create_table "favorites", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "media_entry_id"
  end

  add_index "favorites", ["user_id", "media_entry_id"], :name => "index_favorites_on_user_id_and_media_entry_id", :unique => true

  create_table "groups", :force => true do |t|
    t.string "name"
    t.string "ldap_id"
    t.string "ldap_name"
    t.string "type",      :default => "Group", :null => false
  end

  add_index "groups", ["ldap_id"], :name => "index_groups_on_ldap_id"
  add_index "groups", ["ldap_name"], :name => "index_groups_on_ldap_name"
  add_index "groups", ["type"], :name => "index_groups_on_type"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id", :unique => true
  add_index "groups_users", ["user_id"], :name => "index_groups_users_on_user_id"

  create_table "keywords", :force => true do |t|
    t.integer  "meta_term_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "keywords", ["created_at"], :name => "index_keywords_on_created_at"
  add_index "keywords", ["meta_term_id", "user_id"], :name => "index_keywords_on_term_id_and_user_id"
  add_index "keywords", ["user_id"], :name => "index_keywords_on_user_id"

  create_table "media_entries", :force => true do |t|
    t.integer  "upload_session_id"
    t.integer  "media_file_id"
    t.boolean  "delta",             :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media_entries", ["delta"], :name => "index_media_entries_on_delta"
  add_index "media_entries", ["media_file_id"], :name => "index_media_entries_on_media_file_id"
  add_index "media_entries", ["updated_at"], :name => "index_media_entries_on_updated_at"
  add_index "media_entries", ["upload_session_id"], :name => "index_media_entries_on_upload_session_id"

  create_table "media_entries_media_sets", :id => false, :force => true do |t|
    t.integer "media_set_id"
    t.integer "media_entry_id"
  end

  add_index "media_entries_media_sets", ["media_entry_id"], :name => "index_media_entries_media_sets_on_media_entry_id"
  add_index "media_entries_media_sets", ["media_set_id", "media_entry_id"], :name => "index_albums_media_entries_on_album_id_and_media_entry_id", :unique => true

  create_table "media_files", :force => true do |t|
    t.string   "guid"
    t.text     "meta_data"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "height"
    t.integer  "width"
    t.string   "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_projects_meta_contexts", :id => false, :force => true do |t|
    t.integer "media_project_id"
    t.integer "meta_context_id"
  end

  add_index "media_projects_meta_contexts", ["media_project_id", "meta_context_id"], :name => "index_on_projects_and_contexts", :unique => true

  create_table "media_set_links", :force => true do |t|
    t.integer "ancestor_id"
    t.integer "descendant_id"
    t.boolean "direct"
    t.integer "count"
  end

  add_index "media_set_links", ["ancestor_id"], :name => "index_album_links_on_ancestor_id"
  add_index "media_set_links", ["descendant_id"], :name => "index_album_links_on_descendant_id"

  create_table "media_sets", :force => true do |t|
    t.integer  "user_id"
    t.string   "query"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :default => "Media::Set", :null => false
  end

  add_index "media_sets", ["updated_at"], :name => "index_media_sets_on_updated_at"
  add_index "media_sets", ["user_id"], :name => "index_albums_on_user_id"

  create_table "meta_contexts", :force => true do |t|
    t.boolean "is_user_interface", :default => false
    t.string  "name"
    t.text    "meta_field"
  end

  add_index "meta_contexts", ["name"], :name => "index_meta_contexts_on_name", :unique => true

  create_table "meta_data", :force => true do |t|
    t.integer "resource_id"
    t.string  "resource_type"
    t.integer "meta_key_id"
    t.text    "value"
  end

  add_index "meta_data", ["meta_key_id"], :name => "index_meta_data_on_meta_key_id"
  add_index "meta_data", ["resource_id", "resource_type", "meta_key_id"], :name => "index_meta_data_on_resource_id_and_resource_type_and_meta_key_id", :unique => true

  create_table "meta_key_definitions", :force => true do |t|
    t.integer  "meta_context_id"
    t.integer  "meta_key_id"
    t.text     "meta_field"
    t.integer  "position",        :null => false
    t.string   "key_map"
    t.string   "key_map_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meta_key_definitions", ["meta_context_id", "position"], :name => "index_meta_key_definitions_on_meta_context_id_and_position", :unique => true
  add_index "meta_key_definitions", ["meta_key_id"], :name => "index_meta_key_definitions_on_meta_key_id"

  create_table "meta_keys", :force => true do |t|
    t.string  "label"
    t.string  "object_type"
    t.boolean "is_dynamic"
    t.boolean "is_extensible_list"
  end

  add_index "meta_keys", ["label"], :name => "index_meta_keys_on_label", :unique => true
  add_index "meta_keys", ["object_type"], :name => "index_meta_keys_on_object_type"

  create_table "meta_keys_meta_terms", :id => false, :force => true do |t|
    t.integer "meta_key_id"
    t.integer "meta_term_id"
  end

  add_index "meta_keys_meta_terms", ["meta_key_id", "meta_term_id"], :name => "index_meta_keys_terms_on_meta_key_id_and_term_id", :unique => true

  create_table "meta_terms", :force => true do |t|
    t.string "en_GB"
    t.string "de_CH"
  end

  add_index "meta_terms", ["en_GB", "de_CH"], :name => "index_terms_on_en_GB_and_de_CH"

  create_table "people", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "pseudonym"
    t.date     "birthdate"
    t.date     "deathdate"
    t.string   "nationality"
    t.text     "wiki_links"
    t.boolean  "delta",       :default => true,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_group",    :default => false
  end

  add_index "people", ["delta"], :name => "index_people_on_delta"
  add_index "people", ["firstname"], :name => "index_people_on_firstname"
  add_index "people", ["is_group"], :name => "index_people_on_is_group"
  add_index "people", ["lastname"], :name => "index_people_on_lastname"

  create_table "permissions", :force => true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.text     "actions_object"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["created_at"], :name => "index_permissions_on_created_at"
  add_index "permissions", ["resource_id", "resource_type", "subject_id", "subject_type"], :name => "index_permissions_on_resource__and_subject", :unique => true
  add_index "permissions", ["subject_id", "subject_type"], :name => "index_permissions_on_subject_id_and_subject_type"

  create_table "previews", :force => true do |t|
    t.integer  "media_file_id"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "height"
    t.integer  "width"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "previews", ["media_file_id"], :name => "index_previews_on_media_file_id"

  create_table "snapshots", :force => true do |t|
    t.integer  "media_entry_id"
    t.integer  "media_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "snapshots", ["media_entry_id", "created_at"], :name => "index_snapshots_on_media_entry_id_and_created_at"
  add_index "snapshots", ["media_file_id"], :name => "index_snapshots_on_media_file_id"

  create_table "type_vocabularies", :force => true do |t|
    t.string "term_name"
    t.string "label"
    t.string "definition"
    t.text   "comment"
  end

  create_table "upload_sessions", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_complete", :default => false
  end

  add_index "upload_sessions", ["created_at"], :name => "index_upload_sessions_on_created_at"
  add_index "upload_sessions", ["is_complete"], :name => "index_upload_sessions_on_is_complete"
  add_index "upload_sessions", ["user_id"], :name => "index_upload_sessions_on_user_id"

  create_table "usage_terms", :force => true do |t|
    t.string   "title"
    t.string   "version"
    t.text     "intro"
    t.text     "body"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "person_id"
    t.string   "login",                   :limit => 40
    t.string   "email",                   :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "usage_terms_accepted_at"
    t.string   "password"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["person_id"], :name => "index_users_on_person_id"

end
