ActiveAdmin.register MetaKeyDefinition do
  belongs_to :meta_context

  menu false


  form do |f|
    f.inputs do
      f.input :meta_context
      f.input :meta_key
      f.input :label, as: :string
      f.input :description, as: :string
      f.input :hint, as: :string
      f.input :is_required
      f.input :length_min
      f.input :length_max
    end
    f.actions
  end

  collection_action :reorder, :method => :put do
    meta_context = MetaContext.find(params[:meta_context_id])
    MetaKeyDefinition.transaction do
      # OPTIMIZE workaround for the mysql uniqueness [meta_context_id, position]
      meta_context.meta_key_definitions.update_all("position = (position*-1)", ["id IN (?)", params[:meta_key_definition]])
      # using update_all (instead of update) to avoid instantiating (and validating) the object
      params[:meta_key_definition].each_with_index do |id, index|
        meta_context.meta_key_definitions.update_all(["position = ?", index+1], ["id = ?", id])
      end
    end
    render :nothing => true
  end    

end
