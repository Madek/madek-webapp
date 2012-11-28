ActiveAdmin.register Copyright do
  menu :parent => "Meta"

  actions  :index, :new, :create, :edit, :update, :destroy

  index do
    column :parent_id
    column :id
    column :label
    column :is_default do |x|
      status_tag (x.is_default ? "Yes" : "No"), (x.is_default ? :ok : :warning)
    end
    column :is_custom do |x|
      status_tag (x.is_custom ? "Yes" : "No"), (x.is_custom ? :ok : :warning)
    end
    column do |x|
      r = link_to "Edit", [:edit, :admin, x]
      if x.is_deletable?
        r += " "
        r += link_to "Delete", [:admin, x], :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      r
    end
  end

  form do |f|
    f.inputs do
      f.input :parent
      f.input :label
      f.input :is_default
      f.input :is_custom
      f.input :usage
      f.input :url
    end
    f.actions
  end
  
end
