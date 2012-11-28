ActiveAdmin.register MetaContextGroup do
  menu :parent => "Meta"

  config.sort_order = "position_asc"

  index do
    column :position do |x|
      div :class => "ui-icon ui-icon-arrowthick-2-n-s handler", :"data-url" => reorder_admin_meta_context_groups_path
    end
    column :name
    column :meta_contexts do |x|
      ul
        x.meta_contexts.each do |y|
          li y
        end
    end
    default_actions
  end

  show :title => :name do |x|
    attributes_table :name, :position
    table_for x.meta_contexts, { :class => "index_table sortable" } do |y|
      column :position do
        div :class => "ui-icon ui-icon-arrowthick-2-n-s handler", :"data-url" => reorder_admin_meta_context_group_meta_contexts_path(x)
      end
      column :name
      column :is_user_interface
      column :label
      column :description
      column do |z|
        link_to "View", [:admin, z]
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  collection_action :reorder, :method => :put do
    MetaContextGroup.transaction do
      # using update_all (instead of update) to avoid instantiating (and validating) the object
      params[:meta_context_group].each_with_index do |id, index|
        MetaContextGroup.update_all({position: (index+1)}, {id: id})
      end
    end
    render :nothing => true
  end    
  
end
