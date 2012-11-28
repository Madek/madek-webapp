ActiveAdmin.register UsageTerm do
  menu :parent => "Settings"

  index do
    column :id
    column :title
    column :version
    column :intro
    default_actions
  end
  
  show do
    render :partial => "users/usage_term", :locals => {:usage_term => usage_term}
  end
  
end
