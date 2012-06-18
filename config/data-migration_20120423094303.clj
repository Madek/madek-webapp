{

:source
   {:subprotocol "mysql",
    :classname "com.mysql.jdbc.Driver",
    :subname "//localhost:3306/madek_prod",
    :user "root",
    :password ""}

:target
   {:subprotocol "postgresql",
    :classname "org.postgresql.Driver",
    :subname "//localhost:5432/madek_prod",
    :user "postgres",
    :password ""},

:reset_pg_sequences true,
:disable_triggers false,

:tables [

  "people"
  "users"
  "groups"
  "groups_users"
  "usage_terms"

  "media_files"
  "previews"
  "media_resources"
  "media_resource_arcs"
  "media_sets_meta_contexts"

  "grouppermissions"
  "userpermissions"
  "permission_presets"

  "edit_sessions"
  "favorites"

  "copyrights"
  "meta_terms"
  "meta_context_groups"
  "meta_contexts"
  "meta_keys"
  "meta_key_definitions"
  "meta_keys_meta_terms"
  "meta_data"
  "keywords"

  "wiki_pages"
  "wiki_page_versions"

;;  "full_texts"
  "settings"
  ]

}
