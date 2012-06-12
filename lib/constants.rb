module Constants 

  extend self

  # update this when adding/removing tables; order must be such that
  #   later reference to previous, never the other way round
  ALL_TABLES = [
    "users", 
    "people",
    "groups",
    "groups_users",
    #
    "media_files",
    "media_resources",
    "media_resource_arcs",
    "previews",
    "full_texts",
    #
    "copyrights",
    "meta_data",
    "meta_keys",
    "meta_terms", 
    "meta_keys_meta_terms",
    "meta_context_groups", 
    "meta_contexts",
    "meta_key_definitions",
    "edit_sessions",
    "favorites",
    "keywords",
    "media_sets_meta_contexts",
    "meta_data_meta_departments",
    "meta_data_meta_terms",
    "meta_data_people",
    "meta_data_users",
    #
    "permission_presets",
    "grouppermissions",
    "userpermissions",
    #
    "settings",
    "usage_terms",
    "wiki_pages",
    "wiki_page_versions"
  ]

  MINIMAL_META_TABLES = [ 
    "meta_keys",
    "meta_terms", "meta_keys_meta_terms",
    "meta_context_groups", "meta_contexts",
    "meta_key_definitions",
    "permission_presets",
    "usage_terms",
    "copyrights"]

  PUBLIC_PREFIX= "perm_public_may_"
 
  NEW_OLD_PUBLIC_ACTIONS_MAP =  \
    { download: :hi_res \
    , view: :view
    }

  NEW_OLD_ACTIONS_MAP = NEW_OLD_PUBLIC_ACTIONS_MAP.merge (
    { edit: :edit \
    , manage: :manage
    })

  PUBLIC_ACTIONS= NEW_OLD_PUBLIC_ACTIONS_MAP.keys
  ACTIONS= NEW_OLD_ACTIONS_MAP.keys


  module Actions 
    extend self

    class << self 
      include Enumerable

      def new2old old_action
        Constants::NEW_OLD_ACTIONS_MAP.fetch old_action.to_sym
      end

      def old2new new_action
        Constants::NEW_OLD_ACTIONS_MAP.invert.fetch new_action.to_sym
      end

      def each
        ACTIONS.each {|action| yield action}
      end

    end

  end

  
  module PublicActions
    extend self

    class << self
      include Enumerable

      def each 
        PUBLIC_ACTIONS.each {|action| yield action}
      end
    end
  end

end
