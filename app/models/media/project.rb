class Media::Project < Media::Set

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_projects_meta_contexts,
                                                :foreign_key => :media_project_id


  # TODO this is used to construct url_path and partials, find a better solution!!! (route alias, ...)
  def self.model_name
    superclass.model_name
  end

end
