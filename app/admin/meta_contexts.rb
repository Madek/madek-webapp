ActiveAdmin.register MetaContext do
  belongs_to :meta_context_group, :optional => true

  menu :parent => "Meta"

  config.sort_order = "meta_context_group_id_asc, position_asc"
  
  index do
    column :name
    column :meta_context_group
    column :position
    column :label
    column :description
    column :is_user_interface do |x|
      status_tag (x.is_user_interface ? "Yes" : "No"), (x.is_user_interface ? :ok : :warning)
    end
    column do |x|
      link_to "View", [:admin, x]
    end
  end

  action_item only:[:show] do
    link_to "Add Key", new_admin_meta_context_meta_key_definition_path(meta_context)
  end
 
  show :title => :name do |x|
    attributes_table :name, :position
    table_for x.meta_key_definitions, { :class => "index_table sortable" } do |y|
      column :position do
        div :class => "ui-icon ui-icon-arrowthick-2-n-s handler", :"data-url" => reorder_admin_meta_context_meta_key_definitions_path(x)
      end
      column :meta_key
      column :key_map
      column :key_map_type
      column :label
      column :description
      column :hint
      column :is_required do |z|
        status_tag (z.is_required ? "Yes" : "No"), (z.is_required ? :ok : :warning)
      end
      column :actions do |z|
        r = link_to "Edit", [:edit, :admin, x, z]
        r += " "
        r += link_to "Delete", [:admin, x, z], :method => :delete, :data => {:confirm => "Are you sure?"}
        r
      end
    end
  end

  form :partial => "form"
  
  collection_action :reorder, :method => :put do
    meta_context_group = MetaContextGroup.find(params[:meta_context_group_id])
    MetaContext.transaction do
      # OPTIMIZE keep [meta_context_group_id, position] unique: 
      meta_context_group.meta_contexts.update_all("position = (position*-1)", ["id IN (?)", params[:meta_context]])
      # using update_all (instead of update) to avoid instantiating (and validating) the object
      params[:meta_context].each_with_index do |id, index|
        meta_context_group.meta_contexts.update_all(["position = ?", index+1], ["id = ?", id])
      end
    end
    render :nothing => true
  end    

end
