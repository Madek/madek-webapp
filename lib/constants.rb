module Constants 

  extend self

  # update this when adding/removing tables; order must be such that
  #   later reference to previous, never the other way round
  ALL_TABLES = [
    "people",
    "users", 
    "groups",
    "groups_users",
    #
    "media_files",
    "media_resources",
    "media_resource_arcs",
    "previews",
    "full_texts",
    #
    "permission_presets",
    "grouppermissions",
    "userpermissions",
    #
    "copyrights",
    "meta_keys",
    "meta_data",
    "meta_terms", 
    "meta_keys_meta_terms",
    "meta_context_groups", 
    "meta_contexts",
    "meta_key_definitions",
    "keywords",
    "media_sets_meta_contexts",
    "meta_data_meta_departments",
    "meta_data_meta_terms",
    "meta_data_people",
    "meta_data_users",
    #
    "edit_sessions",
    "favorites",
    #
    "settings",
    "usage_terms",
  ]

  MINIMAL_META_TABLES = [ 
    "meta_keys",
    "meta_terms", "meta_keys_meta_terms",
    "meta_context_groups", "meta_contexts",
    "meta_key_definitions",
    "permission_presets",
    "usage_terms",
    "copyrights"]

  Actions = [:download, :edit, :manage, :view]

end
